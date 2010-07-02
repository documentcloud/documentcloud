module DC
  module Search

    # A Search::SolrQuery is the structured form of a fielded search, and knows
    # how to generate all of the Solr needed to run and paginate the search.
    # Queries can be run authenticated as an account/organization, as well
    # as unrestricted (pass :unrestricted => true).
    class SolrQuery
      include DC::Access

      FACET_OPTIONS = {
        :all      => {:limit => 6,   :sort => :count},
        :specific => {:limit => 500, :sort => :count}
      }

      attr_reader   :text, :fields, :projects, :attributes, :conditions, :results, :solr
      attr_accessor :page, :page_size, :order, :from, :to, :total

      # Queries are created by the Search::Parser, which sets them up with the
      # appropriate attributes.
      def initialize(opts={})
        @text                   = opts[:text]
        @page                   = opts[:page]
        @fields                 = opts[:fields]       || []
        @projects               = opts[:projects]     || []
        @attributes             = opts[:attributes]   || []
        @from, @to, @total      = nil, nil, nil
        @account, @organization = nil, nil
        @page_size              = DEFAULT_PAGE_SIZE
        @order                  = DEFAULT_ORDER
        @solr                   = Sunspot.new_search(Document)
      end

      # Series of attribute checks to determine the kind and state of query.
      %w(text fields projects attributes results).each do |att|
        class_eval "def has_#{att}?; @#{att}.present?; end"
      end

      # Set the page of the search that this query is supposed to access.
      def page=(page)
        @page = page
        @from = (@page - 1) * @page_size
        @to   = @from + @page_size
      end

      # Generate all of the SQL, including conditions and joins, that is needed
      # to run the query.
      def generate_search
        build_text       if     has_text?
        build_fields     if     has_fields?
        build_projects   if     has_projects?
        build_attributes if     has_attributes?
        build_facets     if     @include_facets
        build_access     unless @unrestricted
        page      = @page
        size      = @facet ? 0 : @page_size
        order     = @order.to_sym
        direction = order == :created_at ? :desc : :asc
        @solr.build do
          order_by  order, direction
          paginate  :page => page, :per_page => size
          data_accessor_for(Document).include = [:organization, :account]
        end
      end

      # Runs (at most) two queries -- one to count the total number of results
      # that match the search, and one that retrieves the documents or notes
      # for the current page.
      def run(o={})
        @account, @organization, @unrestricted = o[:account], o[:organization], o[:unrestricted]
        @include_facets, @facet = o[:include_facets], o[:facet]
        generate_search
        @solr.execute
        @total   = @solr.total
        @results = @solr.results
        Rails.logger.warn @total
        populate_annotation_counts
        populate_highlights if DC_CONFIG['include_highlights']
        self
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
        return false unless has_results? && @account
        counts = Annotation.counts_for_documents(@account, @results)
        @results.each {|doc| doc.annotation_count = counts[doc.id] }
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
          'attributes'  => @attributes
        }.to_json
      end


      private

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

      # Generate the Solr to restrict the search to specific projects.
      def build_projects
        return unless @account
        projects = Project.accessible(@account).all(:conditions => {:title => @projects})
        doc_ids = projects.map(&:document_ids).flatten.uniq
        doc_ids = [-1] if doc_ids.empty?
        if doc_ids.present?
          @populated_projects = true
        else
          doc_ids = [-1]
        end
        @solr.build do
          with :id, doc_ids
        end
      end

      # Generate the SQL to match document attributes.
      # TODO: Fix the special-case for "documents", and "notes" by figuring out
      # a way to do arbitrary translations of faux-attributes.
      def build_attributes
        @attributes.each do |field|
          if ['account', 'notes'].include?(field.kind)
            account = Account.lookup(field.value)
            @solr.build do
              with :account_id, account ? account.id : -1
            end
          elsif field.kind == 'group'
            org = Organization.find_by_slug(field.value)
            @solr.build do
              with :organization_id, org ? org.id : -1
            end
          else
            @solr.build do
              fulltext field.value do
                fields field.kind
              end
            end
          end
        end
      end

      # Add facet results to the search, if requested.
      def build_facets
        specific = @facet
        @solr.build do
          if specific
            args = [specific.to_sym, FACET_OPTIONS[:specific]]
          else
            args = Document::SEARCHABLE_ENTITIES + [FACET_OPTIONS[:all]]
          end
          facet *args
        end
      end

      # Restrict accessible documents for a given account/organzation.
      # Either the document itself is public, or it belongs to us, or it belongs to
      # our organization and we're allowed to see it, or if it belongs to a
      # project that's been shared with us.
      def build_access
        return if @populated_projects
        account, organization = @account, @organization
        shared_ids = has_projects? ? nil : (account && account.shared_document_ids)
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
            if shared_ids && shared_ids.present?
              with      :id, shared_ids
            end
          end
        end
      end

    end

  end
end