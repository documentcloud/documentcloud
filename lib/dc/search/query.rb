module DC
  module Search

    # A Search::Query is the structured form of a fielded search, and knows
    # how to generate all of the SQL needed to run and paginate the search.
    # Queries can be run authenticated as an account/organization, as well
    # as unrestricted (pass :unrestricted => true).
    class Query

      attr_reader   :text, :fields, :labels, :attributes, :conditions, :results
      attr_accessor :page, :from, :to, :total

      # tsearch ranking modifiers
      # 0 (the default) ignores the document length
      # 1 divides the rank by 1 + the logarithm of the document length
      # 2 divides the rank by the document length
      # 4 divides the rank by the mean harmonic distance between extents (this is implemented only by ts_rank_cd)
      # 8 divides the rank by the number of unique words in document
      # 16 divides the rank by 1 + the logarithm of the number of unique words in document
      # 32 divides the rank by itself + 1
      RANK_OPTIONS = 4 | 2 | 32

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

      # Series of attribute checks to determine the kind and state of query.
      %w(text fields labels attributes results).each do |att|
        class_eval "def has_#{att}?; @#{att}.present?; end"
      end

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
        doc_proxy = @unrestricted ? Document : Document.accessible(@account, @organization)
        if @page
          @total = doc_proxy.count(options)
          options[:limit]   = PAGE_SIZE
          options[:offset]  = @from
        end
        @results = doc_proxy.chronological.all(options)
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
        # quoted = @text[Matchers::QUOTED_VALUE, 1]
        # like_part = quoted ? ' and text ilike ?' : ''
        @sql << "(full_text_text_vector @@ plainto_tsquery(?) or documents_title_vector @@ plainto_tsquery(?))"
        @interpolations += [@text, @text]
        # @interpolations << "%#{quoted}%" if quoted
        @joins << :full_text
        # TODO: Find the proper way to sanitize the values in active record.
        # Phrase-based searches, not working yet:
        # @joins << "INNER JOIN (
        #   SELECT document_id, sum(rank) AS rank FROM (
        #     SELECT id AS document_id, ts_rank_cd(documents_title_vector, query, #{RANK_OPTIONS}) AS rank
        #     FROM documents, plainto_tsquery('#{@text.gsub(/'/, "''")}') query
        #     WHERE documents_title_vector @@ query
        #   UNION
        #     SELECT document_id, ts_rank_cd(full_text_text_vector, query, #{RANK_OPTIONS})
        #     FROM full_text, plainto_tsquery('#{@text.gsub(/'/, "''")}') query
        #     WHERE full_text_text_vector @@ query
        #   ) ranks GROUP by document_id
        # ) merged ON document_id = documents.id AND rank > 0.0001
        # "
      end

      # Generate the SQL to search across the fielded metadata.
      def generate_fields_sql
        intersections = []
        @fields.each do |field|
          intersections << "(select document_id from metadata m where (m.kind = ? and metadata_value_vector @@ plainto_tsquery(?)))"
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
      # TODO: Fix the special-case for "account" by figuring out a way to do
      # arbitrary translations of faux-attributes.
      # TODO: Remove sql injection potential in field.kind.
      def generate_attributes_sql
        @attributes.each do |field|
          if field.kind == 'account'
            account = Account.find_by_email(field.value)
            @sql << "documents.account_id = ?"
            @interpolations << (account ? account.id : -1)
          else
            @sql << "documents_#{field.kind}_vector @@ plainto_tsquery(?)"
            @interpolations << field.value
          end
        end
      end

    end

  end
end