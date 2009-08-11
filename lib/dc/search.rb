module DC
  
  # The Search module takes in a raw query string, processes it, queries
  # our backing stores for the most relevant results, and merges the result
  # sets together according to a strategy of our choosing.
  #
  # TODO: Split out some senible kind of logic for merging result sets -- we 
  # need it both here and in multi-fielded metadata search, and use that to
  # replace these broken hashes.
  module Search
    
    def self.find(query, opts={})
      metadata_store  = Store::MetadataStore.new
      full_text_store = Store::FullTextStore.new
      results         = []
      
      query = Parser.new.parse(query) if query.is_a? String
                  
      if query.fielded?
        metadata = metadata_store.find_by_fields(query.fields, opts)
        metadata.each {|meta| results << meta.document }
      end
      
      if query.textual?
        docs = full_text_store.find(query.phrase, opts)
        text_ids = docs.map(&:id)
        if query.fielded?
          results = results.select {|doc| text_ids.include?(doc.id) }
        else
          results = docs
        end
      end
      
      # FIXME: Uniq isn't working, despite implementing Document#hash and 
      # Document#eql?, so hash it ourselves for now.
      results.inject({}) {|h, doc| h[doc.id] = doc; h}.values
    end
    
  end
  
end
