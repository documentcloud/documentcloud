module DC
  
  # The Search module takes in a raw query string, processes it, queries
  # our backing stores for the most relevant results, and mergest the result
  # sets together according to a strategy of our choosing.
  module Search
    
    def self.find(query_string, opts={})
      parser          = Parser.new
      metadata_store  = Store::MetadataStore.new
      full_text_store = Store::FullTextStore.new
      results         = []
      query           = parser.parse(query_string)
      
      if !query.fields.empty?
        metadata = metadata_store.find_by_fields(query.fields, opts)
        results += metadata.map {|m| m.document }
      end
      
      if query.phrase
        results += full_text_store.find(query.phrase, opts)
      end
      
      results
    end
    
  end
  
end
