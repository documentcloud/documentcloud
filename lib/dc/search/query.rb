module DC
  module Search

    # A Search::Query is the structured form of a fielded search, and knows
    # how to generate all of the Solr needed to run and paginate the search.
    # Queries can be run authenticated as an account/organization, as well
    # as unrestricted (pass :unrestricted => true).
    #
    # If the query doesn't need to hit Solr -- if we're just looking at all
    # documents in a specific project, or all documents belonging to an account,
    # just use Postgres.
    class Query
      include DC::Access

      FACET_OPTIONS = {
        :all      => {:limit => 6,   :sort => :count},
        :specific => {:limit => 500, :sort => :count}
      }

      EMPTY_PAGINATION = {:page => 1, :per_page => 0}

      attr_reader   :text, :fields, :projects, :accounts, :groups, :project_ids, :doc_ids, :filters, :access, :attributes, :conditions, :results, :solr, :source_document
      attr_accessor :page, :per_page, :order, :from, :to, :total

      # Queries are created by the Search::Parser, which sets them up with the
      # appropriate attributes.
      def initialize(opts={})
        @text                   = opts[:text]
        @page                   = opts[:page]
        @access                 = opts[:access]
        @fields                 = opts[:fields]       || []
        @accounts               = opts[:accounts]     || []
        @groups                 = opts[:groups]       || []
        @projects               = opts[:projects]     || []
        @project_ids            = opts[:project_ids]  || []
        @doc_ids                = opts[:doc_ids]      || []
        @attributes             = opts[:attributes]   || []
        @filters                = opts[:filters]      || []
        @source_document        = opts[:source_document]
        @from, @to, @total      = nil, nil, nil
        @account, @organization = nil, nil
        @per_page               = DEFAULT_PER_PAGE
        @order                  = DEFAULT_ORDER
      end

      # Series of attribute checks to determine the kind and state of query.
      [:text, :fields, :projects, :accounts, :groups, :project_ids, :doc_ids, :attributes, :results, :filters, :access, :source_document].each do |att|
        class_eval "def has_#{att}?; @has_#{att} ||= @#{att}.present?; end"
      end

      # Set the page of the search that this query is supposed to access.
      def page=(page)
        @page = page
        @from = (@page - 1) * @per_page
        @to   = @from + @per_page
      end

      # Generate all of the SQL, including conditions and joins, that is needed
      # to run the query.
      def generate_search
        build_related      if     has_source_document?
        build_text         if     has_text? && !has_source_document?
        build_fields       if     has_fields?
        build_accounts     if     has_accounts?
        build_groups       if     has_groups?
        build_project_ids  if     has_project_ids?
        build_projects     if     has_projects?
        build_doc_ids      if     has_doc_ids?
        build_attributes   if     has_attributes? && !has_source_document?
        build_filters      if     has_filters?
        build_facets       if     @include_facets
        build_access       unless @unrestricted
      end

      # Runs (at most) two queries -- one to count the total number of results
      # that match the search, and one that retrieves the documents or notes
      # for the current page.
      def run(o={})
        @account, @organization, @unrestricted = o[:account], o[:organization], o[:unrestricted]
        @include_facets, @facet = o[:include_facets], o[:facet]
        @exclude_documents = o[:exclude_documents]
        needs_solr? ? run_solr : run_database
        populate_annotation_counts
        populate_highlights if DC_CONFIG['include_highlights']
        self
      end

      # Does this query require the Solr index to run?
      def needs_solr?
        @needs_solr ||= (@include_facets || has_text? || has_fields? || has_source_document? || has_attributes?)
      end

      # If we've got a full text search with results, we can get Postgres to
      # generate the text highlights for our search results.
      def populate_highlights
        return false unless has_text? and has_results?
        highlights = FullText.highlights(@results, @text)
        @results.each {|doc| doc.highlight = highlights[doc.id] }
      end

      # Stash the number of notes per-document on the document models.
      def populate_annotation_counts
        return false unless has_results?
        Document.populate_annotation_counts(@account, @results)
      end

      # Return a hash of facets.
      def facets
        return {} unless @include_facets
        @solr.facets.inject({}) do |hash, facet|
          hash[facet.field_name] = facet.rows.map {|row| {:value => row.value, :count => row.count}}
          hash
        end
      end

      # The JSON representation of a query contains all the structured aspects
      # of the search.
      def to_json(opts={})
        { 'text'        => @text,
          'page'        => @page,
          'from'        => @from,
          'to'          => @to,
          'total'       => @total,
          'fields'      => @fields,
          'projects'    => @projects,
          'accounts'    => @accounts,
          'groups'      => @groups,
          'project_ids' => @project_ids,
          'doc_ids'     => @doc_ids,
          'attributes'  => @attributes
        }.to_json
      end


      private

      # Run the search, using the Solr index.
      def run_solr
        @solr = has_source_document? ?
          Sunspot.new_more_like_this(@source_document, Document) :
          Sunspot.new_search(Document)
        generate_search
        build_pagination
        @solr.execute
        @total   = @solr.total
        @results = @solr.results
      end

      # Run the search using Postgres.
      def run_database
        @sql, @interpolations, @joins = [], [], []
        @proxy = Document
        generate_search
        conditions        = [@sql.join(' and ')] + @interpolations
        order             = "documents.created_at desc"
        direction         = [:page_count, :hit_count].include?(@order.to_sym) ? 'desc' : 'asc'
        order             = "documents.#{@order} #{direction}, #{order}" unless [:created_at, :score].include?(@order.to_sym)
        options           = {:conditions => conditions, :joins => @joins, :include => [:account, :organization]}
        @total            = @proxy.count(options)
        options[:order]   = order
        options[:limit]   = @per_page
        options[:offset]  = @from
        @results          = @proxy.all(options)
      end

      # Construct the correct pagination for the current query.
      def build_pagination
        page       = @page
        size       = @facet ? 0 : @per_page
        order      = @order.to_sym
        direction  = [:created_at, :score, :page_count, :hit_count].include?(order) ? :desc : :asc
        pagination = {:page => page, :per_page => size}
        pagination = EMPTY_PAGINATION if @exclude_documents
        related    = has_source_document?
        @solr.build do
          order_by  order, direction
          order_by  :created_at, :desc if order != :created_at
          paginate  pagination
          data_accessor_for(Document).include = [:organization, :account] unless related
        end
      end

      # Build the Solr needed to pass options to the MoreLikeThis DSL
      def build_related
        @solr.build do
          minimum_term_frequency 15
          minimum_document_frequency 2
          minimum_word_length 8
          boost_by_relevance true
        end
      end

      # Build the Solr needed to run a full-text search. Hits the title,
      # the text content, the entities, etc.
      def build_text
        text = @text
        @solr.build do
          fulltext text
        end
      end

      # Generate the Solr to search across the fielded metadata.
      def build_fields
        fields = @fields
        related = has_source_document?
        @solr.build do
          fields.each do |field|
            if related
              with field.kind, field.value
            else
              fulltext field.value do
                fields field.kind
              end
            end
          end
        end
      end

      # Lookup projects by title, and delegate to `build_project_ids`.
      def build_projects
        return unless @account
        projects = Project.accessible(@account).all(:conditions => {:title => @projects})
        doc_ids = projects.map{|proj| proj.document_ids }.flatten.uniq
        doc_ids = [-1] if doc_ids.empty?
        if doc_ids.present?
          @populated_projects = true
        else
          project_ids = [-1]
        end
        @project_ids = project_ids
        build_project_ids
      end

      # Generate the Solr or SQL to restrict the search to specific projects.
      def build_project_ids
        ids = @project_ids
        if needs_solr?
          @solr.build do
            with :project_ids, ids
          end
        else
          @sql << 'projects.id in (?)'
          @interpolations << @project_ids
          @joins << 'inner join project_memberships ON documents.id = document_id
                     inner join projects on project_id = projects.id'
        end
      end

      # Generate the Solr or SQL to restrict the search to specific documents.
      def build_doc_ids
        ids = @doc_ids
        if needs_solr?
          @solr.build do
            with :id, ids
          end
        else
          @sql << 'documents.id in (?)'
          @interpolations << ids
        end
      end

      # Generate the Solr or SQL to restrict the search to specific acounts.
      def build_accounts
        ids = @accounts
        if needs_solr?
          @solr.build do
            with :account_id, ids
          end
        else
          @sql << 'documents.account_id in (?)'
          @interpolations << ids
        end
      end

      # Generate the Solr or SQL to restrict the search to specific organizations.
      def build_groups
        organzations = @groups.map {|slug| Organization.find_by_slug(slug, :select => 'id') }
        ids          = organzations.map {|org| org ? org.id : -1 }
        if needs_solr?
          @solr.build do
            with :organization_id, ids
          end
        else
          @sql << 'documents.organization_id in (?)'
          @interpolations << ids
        end
      end

      # Generate the Solr to match document attributes.
      def build_attributes
        @attributes.each do |field|
          @solr.build do
            fulltext field.value do
              fields field.kind
            end
          end
        end
      end

      # Add facet results to the Solr search, if requested.
      def build_facets
        specific = @facet
        @solr.build do
          if specific
            args = [specific.to_sym, FACET_OPTIONS[:specific]]
          else
            args = DC::ENTITY_KINDS + [FACET_OPTIONS[:all]]
          end
          facet(*args)
        end
      end

      # Filter documents along certain "interesting axes".
      def build_filters
        @filters.each do |filter|
          case filter
          when :annotated
            if needs_solr?
              # NB: Solr "greater_than" is actually >=
              @solr.build { with(:public_note_count).greater_than(1) }
            else
              @sql << 'documents.public_note_count > 0'
            end
          when :popular
            @order = :hit_count
            if needs_solr?
              @solr.build { with(:hit_count).greater_than(Document::MINIMUM_POPULAR) }
            else
              @sql << 'documents.hit_count > ?'
              @interpolations << [Document::MINIMUM_POPULAR]
            end
          when :published
            if needs_solr?
              @solr.build { with :published, true }
            else
              @sql << 'documents.access in (?) and (documents.remote_url is not null or documents.detected_remote_url is not null)'
              @interpolations << [PUBLIC, EXCLUSIVE]
            end
          when :unpublished
            if needs_solr?
              @solr.build { with :published, false }
            else
              @sql << 'documents.remote_url is null and documents.detected_remote_url is null'
            end
          end
        end
      end

      # Restrict accessible documents for a given account/organzation.
      # Either the document itself is public, or it belongs to us, or it belongs to
      # our organization and we're allowed to see it, or if it belongs to a
      # project that's been shared with us, or it belongs to a project that
      # *hasn't* been shared with us, but is public.
      def build_access
        @proxy = Document.accessible(@account, @organization) unless needs_solr?
        if has_access?
          access = @access
          if needs_solr?
            @solr.build do
              with :access, access
            end
          else
            @sql << 'documents.access = ?'
            @interpolations << access
          end
        end
        return unless needs_solr?
        return if @populated_projects
        account, organization  = @account, @organization
        accessible_project_ids = has_projects? || has_project_ids? ? [] : (account && account.accessible_project_ids)
        @solr.build do
          any_of do
            with        :access, PUBLIC
            if account
              all_of do
                with    :access, [PRIVATE, PENDING, ERROR]
                with    :account_id, account.id
              end
            end
            if organization
              all_of do
                with    :access, [ORGANIZATION, EXCLUSIVE]
                with    :organization_id, organization.id
              end
            end
            if accessible_project_ids.present?
              with      :project_ids, accessible_project_ids
            end
          end
        end
      end

    end

  end
end
