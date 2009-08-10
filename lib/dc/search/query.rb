module DC
  module Search
    
    class Query
      
      attr_reader :phrase, :fields
      
      def initialize(opts={})
        @phrase = opts[:phrase]
        @fields = opts[:fields] || []
      end
      
      # Does this query search by field?
      def fielded?
        !@fields.empty?
      end
      
      # Does this query incorporate full-text search?
      def textual?
        !!@phrase
      end
      
      # Does this query include multiple kinds of search?
      def compound?
        fielded? && textual?
      end
      
    end
    
  end
end