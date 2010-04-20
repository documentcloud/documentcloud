module DC
  module Search

    # A Search::SolrQuery is the structured form of a fielded search, and knows
    # how to generate all of the Solr needed to run and paginate the search.
    # Queries can be run authenticated as an account/organization, as well
    # as unrestricted (pass :unrestricted => true).
    class SolrQuery
      include DC::Access

      FACET_OPTIONS = {:limit => 5, :sort => :count}

      attr_reader   :text, :fields, :projects, :attributes, :conditions, :results, :solr
      attr_accessor :page, :from, :to, :total

      # Queries are created by the Search::Parser, which sets them up with the
      # appropriate attributes.
      def initialize(opts={})
        @text                   = opts[:text]
        @page                   = opts[:page]
        @fields                 = opts[:fields] || []
        @projects               = opts[:projects] || []
        @attributes             = opts[:attributes] || []
        @from, @to, @total      = nil, nil, nil
        @account, @organization = nil, nil
        @solr                   = Sunspot.new_search(Document)
      end

      # Series of attribute checks to determine the kind and state of query.
      %w(text fields projects attributes results).each do |att|
        class_eval "def has_#{att}?; @#{att}.present?; end"
      end

      # Set the page of the search that this query is supposed to access.
      def page=(page)
        @page = page
        @from = (@page - 1) * PAGE_SIZE
        @to   = @from + PAGE_SIZE
      end

      # Generate all of the SQL, including conditions and joins, that is needed
      # to run the query.
      def generate_search
        build_text       if     has_text?
        build_fields     if     has_fields?
        build_projects   if     has_projects?
        build_attributes if     has_attributes?
        build_facets     if     @faceted
        build_access     unless @unrestricted
        page, size = @page, PAGE_SIZE
        @solr.build do
          order_by  :created_at, :desc
          paginate  :page => page, :per_page => size
        end
      end

      # Runs (at most) two queries -- one to count the total number of results
      # that match the search, and one that retrieves the documents or notes
      # for the current page.
      def run(o={})
        @account, @organization, @unrestricted, @faceted = o[:account], o[:organization], o[:unrestricted], o[:facets]
        generate_search
        @solr.execute
        @total   = @solr.total
        @results = @solr.results
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
        return {} unless @faceted
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
        projects = @account.projects.all(:conditions => {:title => @projects})
        doc_ids = projects.map(&:document_ids).flatten.uniq
        doc_ids = [-1] if doc_ids.empty?
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
            account = Account.find_by_email(field.value)
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
        @solr.build do
          args = Document::SEARCHABLE_ENTITIES + [FACET_OPTIONS]
          facet *args
        end
      end

      # Restrict accessible documents for a given account/organzation.
      # Either the document itself is public, or it belongs to us, or it belongs to
      # our organization and we're allowed to see it.
      def build_access
        account, organization = @account, @organization
        @solr.build do
          any_of do
            with      :access, PUBLIC
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
          end
        end
      end

    end

  end
end