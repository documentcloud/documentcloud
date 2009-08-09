module DC
  module Search
    
    class Query
      
      attr_reader :phrase, :fields
      
      def initialize(opts={})
        @phrase = opts[:phrase]
        @fields = opts[:fields] || []
      end
      
    end
    
  end
end