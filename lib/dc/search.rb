module DC
  
  # The Search module takes in a raw query string, processes it, queries
  # our backing stores for the most relevant results, and merges the result
  # sets together according to a strategy of our choosing.
  #
  # TODO: Split out some senible kind of logic for merging result sets -- we 
  # need it both here and in multi-fielded metadata search, and use that to
  # replace these broken hashes.
  module Search
    
    module Matchers
      BARE_FIELD    = /\w+:\s?[^'"]{2}\S*/
      QUOTED_FIELD  = /\w+:\s?['"].+?['"]/
      QUOTED_VALUE  = /\A['"](.+)['"]\Z/
      ALL_FIELDS    = /\w+:\s?((['"].+?['"])|([^'"]{2}\S*))/
      BOOLEAN_OR    = /\s+OR\s+/
    end
    
    SPHINX_OR = ' | '
    
    def self.find(query, opts={})
      metadata_store  = Store::MetadataStore.new
      full_text_store = Store::FullTextStore.new
      entry_store     = Store::EntryStore.new
      results         = []
      
      query = Parser.new.parse(query) if query.is_a? String
              
      # TODO: Think about where the title and source should really belong.    
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
            
      results += entry_store.find_by('title', query.title_query) if query.title_query      
      results += entry_store.find_by('organization', query.source_query) if query.source_query
      
      # FIXME: Uniq isn't working, despite implementing Document#hash and 
      # Document#eql?, so hash it ourselves for now.
      docs = results.inject({}) {|h, doc| h[doc.id] = doc; h}.values
      DocumentSet.new(docs)
    end
    
  end
  
end
