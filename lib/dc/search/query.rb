module DC
  module Search
    
    # A Search::Query is almost a struct, holding all the segregated components
    # that can go into a single document search.
    class Query
      
      attr_reader   :text, :fields, :labels, :attributes, :conditions
      attr_accessor :page, :from, :to, :total
      
      def initialize(opts={})
        @text           = opts[:text]
        @page           = opts[:page]
        @fields         = opts[:fields] || []
        @labels         = opts[:labels] || []
        @attributes     = opts[:attributes] || []
        @conditions     = nil
        @sql            = []
        @interpolations = []
        @joins          = []
      end
      
      # Series of attribute checks to determine the type of query.
    
      def has_text?;        @text.present?;         end
      def has_fields?;      @fields.present?;       end
      def has_labels?;      @labels.present?;       end      
      def has_attributes?;  @attributes.present?;   end
      
      def page=(page)
        @page = page
        @from = @page * PAGE_SIZE
        @to   = @from + PAGE_SIZE        
      end
      
      def generate_sql
        generate_text_sql       if has_text?
        generate_fields_sql     if has_fields?
        generate_labels_sql     if has_labels?
        generate_attributes_sql if has_attributes?
        @conditions = [@sql.join(' and ')] + @interpolations
      end
      
      def run
        generate_sql
        options = {:conditions => @conditions, :joins => @joins}
        if @page
          options[:select] = "distinct documents.id"
          self.total = Document.count(options)
          options[:limit]   = PAGE_SIZE
          options[:offset]  = @from
        end
        options[:select] = "distinct on (documents.id) documents.*"
        Document.all(options)
      end
      
      # The json representation of a Search::Query includes all the instance
      # variables.
      def to_json(opts={})
        instance_variables.inject({}) {|memo, var| 
          memo[var[1..-1]] = instance_variable_get(var)
          memo
        }.to_json
      end
      
      
      private
      
      def generate_text_sql
        @sql << "to_tsvector('english', full_text.text) @@ plainto_tsquery(?)"
        @interpolations << @text
        @joins << :full_text
      end
      
      def generate_fields_sql
        intersections = []
        @fields.each do |field|
          intersections << "(select document_id from metadata m where (m.kind = ? and to_tsvector('english', m.value) @@ plainto_tsquery(?)))"
          @interpolations += [field.kind, field.value]
        end
        @sql << "documents.id in (#{intersections.join(' intersect ')})"
      end
      
      def generate_labels_sql
        labels = Account.current.labels.all(:conditions => {:title => @labels})
        doc_ids = labels.map(&:split_document_ids).flatten.uniq        
        @sql << "documents.id in (?)"
        @interpolations << doc_ids
      end
      
      def generate_attributes_sql
        @attributes.each do |field|
          @sql << "documents.#{field.kind} = ?"
          @interpolations << field.value
        end
      end
      
    end
    
  end
end