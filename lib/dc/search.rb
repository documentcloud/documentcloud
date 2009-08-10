module DC
  
  # The Search module takes in a raw query string, processes it, queries
  # our backing stores for the most relevant results, and mergest the result
  # sets together according to a strategy of our choosing.
  #
  # TODO: Split out some senible kind of logic for merging result sets -- we 
  # need it both here and in multi-fielded metadata search, and use that to
  # replace these broken hashes.
  module Search
    
    def self.find(query_string, opts={})
      parser          = Parser.new
      metadata_store  = Store::MetadataStore.new
      full_text_store = Store::FullTextStore.new
      query           = parser.parse(query_string)
      results, counts = {}, Hash.new(0)
      
      if query.fielded?
        metadata = metadata_store.find_by_fields(query.fields, opts)
        metadata.each do |meta| 
          results[meta.document_id] = meta.document
          counts[meta.document_id] += 1
        end
      end
      
      if query.textual?
        docs = full_text_store.find(query.phrase, opts)
        docs.each do |doc| 
          results[doc.id] = doc
          counts[doc.id] += 1
        end
      end
      
      if query.fielded? && query.textual?
        return results.values.select {|doc| counts[doc.id] >= 2} 
      end
      results.values   
    end
    
  end
  
end
