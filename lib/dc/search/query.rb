module DC
  module Search

    # A Search::Query is the structured form of a fielded search, and knows
    # how to generate all of the SQL needed to run and paginate the search.
    # Queries can be run authenticated as an account/organization, as well
    # as unrestricted (pass :unrestricted => true).
    class Query

      attr_reader   :text, :fields, :labels, :attributes, :conditions
      attr_accessor :page, :from, :to, :total

      # Queries are created by the Search::Parser, which sets them up with the
      # appropriate attributes.
      def initialize(opts={})
        @text                   = opts[:text]
        @page                   = opts[:page]
        @fields                 = opts[:fields] || []
        @labels                 = opts[:labels] || []
        @attributes             = opts[:attributes] || []
        @from, @to, @total      = nil, nil, nil
        @account, @organization = nil, nil
        @conditions             = nil
        @sql                    = []
        @interpolations         = []
        @joins                  = []
      end

      # Series of attribute checks to determine the type of query.

      def has_text?;        @text.present?;         end
      def has_fields?;      @fields.present?;       end
      def has_labels?;      @labels.present?;       end
      def has_attributes?;  @attributes.present?;   end

      # Set the page of the search that this query is supposed to access.
      def page=(page)
        @page = page
        @from = @page * PAGE_SIZE
        @to   = @from + PAGE_SIZE
      end

      # Generate all of the SQL, including conditions and joins, that is needed
      # to run the query.
      def generate_sql
        generate_text_sql       if has_text?
        generate_fields_sql     if has_fields?
        generate_labels_sql     if has_labels?
        generate_attributes_sql if has_attributes?
        @conditions = [@sql.join(' and ')] + @interpolations
      end

      # Runs (at most) two queries -- one to count the total number of results
      # that match the search, and one that retrieves the documents for the
      # current page.
      def run(options={})
        @account, @organization, @unrestricted = options[:account], options[:organization], options[:unrestricted]
        generate_sql
        options = {:conditions => @conditions, :joins => @joins}
        if @page
          options[:select] = "distinct documents.id"
          @total = Document.count(options)
          options[:limit]   = PAGE_SIZE
          options[:offset]  = @from
        end
        options[:select] = "distinct on (documents.id) documents.*"
        @unrestricted ? Document.all(options) : Document.accessible(@account, @organization).all(options)
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
          'labels'      => @labels,
          'attributes'  => @attributes
        }.to_json
      end


      private

      # Generate the SQL needed to run a full-text search.
      def generate_text_sql
        @sql << "to_tsvector('english', full_text.text) @@ plainto_tsquery(?)"
        @interpolations << @text
        @joins << :full_text
      end

      # Generate the SQL to search across the fielded metadata.
      def generate_fields_sql
        intersections = []
        @fields.each do |field|
          intersections << "(select document_id from metadata m where (m.kind = ? and to_tsvector('english', m.value) @@ plainto_tsquery(?)))"
          @interpolations += [field.kind, field.value]
        end
        @sql << "documents.id in (#{intersections.join(' intersect ')})"
      end

      # Generate the SQL to restrict the search to labeled documents.
      def generate_labels_sql
        return unless @account
        labels = @account.labels.all(:conditions => {:title => @labels})
        doc_ids = labels.map(&:split_document_ids).flatten.uniq
        @sql << "documents.id in (?)"
        @interpolations << doc_ids
      end

      # Generate the SQL to match document attributes.
      def generate_attributes_sql
        @attributes.each do |field|
          @sql << "documents.#{field.kind} = ?"
          @interpolations << field.value
        end
      end

    end

  end
end