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
        :api      => {:limit => 10,  :sort => :count},
        :specific => {:limit => 500, :sort => :count}
      }

      EMPTY_PAGINATION = {:page => 1, :per_page => 0}

      attr_reader   :text, :fields, :projects, :accounts, :groups, :project_ids, :doc_ids, :filters, :access, :attributes, :data, :conditions, :results, :solr
      attr_accessor :page, :per_page, :order, :from, :to, :total

      # Queries are created by the Search::Parser, which sets them up with the
      # appropriate attributes.
      def initialize(opts={})
        @text                   = opts[:text]
        @page                   = opts[:page].to_i
        @page                   = 1 unless @page > 0
        @access                 = opts[:access]
        @fields                 = opts[:fields]       || []
        @accounts               = opts[:accounts]     || []
        @groups                 = opts[:groups]       || []
        @projects               = opts[:projects]     || []
        @project_ids            = opts[:project_ids]  || []
        @doc_ids                = opts[:doc_ids]      || []
        @attributes             = opts[:attributes]   || []
        @filters                = opts[:filters]      || []
        @data                   = opts[:data]         || []
        @from, @to, @total      = nil, nil, nil
        @account, @organization = nil, nil
        @data_groups            = @data.group_by {|datum| datum.kind }
        @per_page               = DEFAULT_PER_PAGE
        @order                  = DEFAULT_ORDER
      end

      # Series of attribute checks to determine the kind and state of query.
      [:text, :fields, :projects, :accounts, :groups, :project_ids, :doc_ids, :attributes, :data, :results, :filters, :access].each do |att|
        class_eval "def has_#{att}?; @has_#{att} ||= @#{att}.present?; end"
      end

      # Set the page of the search that this query is supposed to access.
      def page=(page)
        raise ArgumentError, "page must be > 0" unless page.to_i > 0
        @page = page.to_i
        @from = (@page - 1) * @per_page
        @to   = @from + @per_page
      end

      # Generate all of the SQL, including conditions and joins, that is needed
      # to run the query.
      def generate_search
        build_text         if     has_text?
        build_fields       if     has_fields?
        build_data         if     has_data?
        build_accounts     if     has_accounts?
        build_groups       if     has_groups?
        build_project_ids  if     has_project_ids?
        build_projects     if     has_projects?
        build_doc_ids      if     has_doc_ids?
        build_attributes   if     has_attributes?
        build_filters      if     has_filters?
        # build_facets       if     @include_facets
        build_access       unless @unrestricted
      end

      # Runs (at most) two queries -- one to count the total number of results
      # that match the search, and one that retrieves the documents or notes
      # for the current page.
      def run(o={})
        @account, @organization, @unrestricted = o[:account], o[:organization], o[:unrestricted]
        @exclude_documents = o[:exclude_documents]
        needs_solr? ? run_solr : run_database
        populate_annotation_counts
        populate_mentions o[:mentions].to_i if o[:mentions]
        self
      end

      # Does this query require the Solr index to run?
      def needs_solr?
        @needs_solr ||= (has_text? || has_fields? || has_attributes?) ||
          @data_groups.any? {|kind, list| list.length > 1 }
      end

      # If we've got a full text search with results, we can get Postgres to
      # generate the text mentions for our search results.
      def populate_mentions(mentions)
        raise "Invalid number of mentions" unless mentions > 0 && mentions <= 10
        return false unless has_text? and has_results?
        @results.each do |doc|
          mention_data        = Page.mentions(doc.id, @text, mentions)
          doc.mentions        = mention_data[:mentions]
          doc.total_mentions  = mention_data[:total]
        end
      end

      # Stash the number of notes per-document on the document models.
      def populate_annotation_counts
        return false unless has_results?
        Document.populate_annotation_counts(@account, @results)
      end

      # # Return a hash of facets.
      # def facets
      #   return {} unless @include_facets
      #   @solr.facets.inject({}) do |hash, facet|
      #     hash[facet.field_name] = facet.rows.map {|row| {:value => row.value, :count => row.count}}
      #     hash
      #   end
      # end

      # The JSON representation of a query contains all the structured aspects
      # of the search.
      def as_json(opts={})
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
          'attributes'  => @attributes,
          'data'        => @data.map {|f| [f.kind, f.value] }
        }
      end


      private

      # Run the search, using the Solr index.
      def run_solr
        @solr = Sunspot.new_search(Document)
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
        query             = @proxy
          .joins( @joins )
          .includes(:account, :organization)
          .references(:account, :organization)
          .where( conditions )
        @total            = query.count
        # options[:order]   = order
        # options[:limit]   = @per_page
        # options[:offset]  = @from
        @results          = query.order( order ).limit( @per_page ).offset( @from )
      end

      # Construct the correct pagination for the current query.
      def build_pagination
        page       = @page
        size       = @per_page
        order      = @order.to_sym
        direction  = [:created_at, :score, :page_count, :hit_count].include?(order) ? :desc : :asc
        pagination = {:page => page, :per_page => size}
        pagination = EMPTY_PAGINATION if @exclude_documents
        @solr.build do
          order_by  order, direction
          order_by  :created_at, :desc if order != :created_at
          paginate  pagination
          data_accessor_for(Document).include = [:organization, :account]
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
        @solr.build do
          fields.each do |field|
            fulltext field.value do
              fields field.kind
            end
          end
        end
      end

      # Lookup projects by title, and delegate to `build_project_ids`.
      def build_projects
        return unless @account
        project_ids = Project.accessible(@account).where(:title => @projects).pluck(:id)
        if project_ids.present?
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
          @joins << 'inner join project_memberships ON documents.id = project_memberships.document_id
                     inner join projects on project_memberships.project_id = projects.id'
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
        ids = Organization.where(:slug => @groups).pluck(:id)
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

      # Generate the Solr or SQL to match user-data queries. If the value
      # is "*", assume that any document that contains the key will do.
      def build_data
        data   = @data
        groups = @data_groups
        if needs_solr?
          @solr.build do
            dynamic :data do
              groups.each do |kind, data|
                any_of do
                  data.each do |datum|
                    if datum.value == '*'
                      without datum.kind, nil
                    elsif datum.value == '!'
                      with datum.kind, nil
                    else
                      with datum.kind, datum.value
                    end
                  end
                end
              end
            end
          end
        else
          hash = {}
          data.each do |datum|
            if datum.value == '*'
              @sql << 'defined(docdata.data, ?)'
              @interpolations << datum.kind
            elsif datum.value == '!'
              @sql << '(docdata.data -> ?) is null'
              @interpolations << datum.kind
            else
              @sql << '(docdata.data -> ?) LIKE ?'
              @interpolations += [datum.kind, datum.value.gsub('*', '%')]
            end
          end
          @joins << 'inner join docdata ON documents.id = docdata.document_id'
        end
      end


      def self.to_hash_query(hash)
        hash.map {|k, v| "\"#{sanitize(k)}\"=>\"#{sanitize(v)}\"" }.join(',')
      end

      def self.sanitize(obj)
        Sanitize.clean(obj.to_s.gsub(/[\\"]/, ''))
      end


      # Add facet results to the Solr search, if requested.
      # def build_facets
      #   api = @include_facets == :api
      #   specific = @facet
      #   @solr.build do
      #     if specific
      #       args = [specific.to_sym, FACET_OPTIONS[:specific]]
      #     else
      #       args = DC::ENTITY_KINDS + [FACET_OPTIONS[api ? :api : :all]]
      #     end
      #     facet(*args)
      #   end
      # end

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
              @interpolations << PUBLIC_LEVELS
            end
          when :unpublished
            if needs_solr?
              @solr.build { with :published, false }
            else
              @sql << 'documents.remote_url is null and documents.detected_remote_url is null'
            end
          when :restricted
            if needs_solr?
              @solr.build { with :access, [PRIVATE, ORGANIZATION, PENDING, INVISIBLE, ERROR, DELETED, EXCLUSIVE] }
            else
              @sql << 'documents.access in (?)'
              @interpolations << [PRIVATE, ORGANIZATION, PENDING, INVISIBLE, ERROR, DELETED, EXCLUSIVE]
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
            with        :access, PUBLIC_LEVELS
            if account
              all_of do
                with    :access, [PRIVATE, PENDING, ERROR, ORGANIZATION, EXCLUSIVE]
                with    :account_id, account.id
              end
            end
            if organization && account && !account.freelancer?
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
