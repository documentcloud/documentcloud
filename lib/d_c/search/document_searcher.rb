module DC
  module Search
    
    # The DocumentSearcher takes in a pre-processed SearchQuery, queries
    # our backing stores for the most relevant results, and merges the result
    # sets together according to a strategy of our choosing.
    class DocumentSearcher
      
      def initialize
        @metadata_store  = DC::Stores::MetadataStore.new
        @full_text_store = DC::Stores::FullTextStore.new
      end
      
      def find(query)
        @metadata_store.find_by_value(query.metadata_value, query.limit) +
        @full_text_store.find(query.search_text, query.limit)
      end
      
    end
    
  end
end