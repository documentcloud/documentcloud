module DC
  module Search
    
    class Query
      
      attr_reader :phrase, :fields, :title, :source
      
      def initialize(opts={})
        @phrase       = opts[:phrase]
        @naked_phrase = @phrase && @phrase.sub(Matchers::QUOTED_VALUE, '\1')
        @fields       = opts[:fields] || []
        @title        = extract_fields('title')
        @source       = extract_fields('source')
      end
      
      def title_query
        @title || @naked_phrase
      end
      
      def source_query
        @source || @naked_phrase
      end
      
      # Does this query search by field?
      def fielded?
        @fields.present?
      end
      
      # Does this query incorporate full-text search?
      def textual?
        @phrase.present?
      end
      
      # Does this query include multiple kinds of search?
      def compound?
        fielded? && textual?
      end
      
      def extract_fields(special)
        matched_fields = @fields.select {|f| f.type == special }
        return nil if matched_fields.empty?
        matched_fields.map {|f| f.value }.join(SPHINX_OR)
      end
      
      def inspect
        phrase = @phrase ? "\"#{@phrase}\"" : ''
        fields = @fields.map(&:to_s).join(' ')
        "#<DC::Search::Query #{phrase} #{fields}>"
      end
      
      def as_json(opts={})
        {
          'phrase' => @phrase,
          'fields' => @fields
        }
      end
      
    end
    
  end
end