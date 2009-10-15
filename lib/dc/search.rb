module DC
  
  # The Search module takes in a raw query string, processes it, queries
  # our backing stores for the most relevant results, and merges the result
  # sets together according to a strategy of our choosing.
  module Search
    
    module Matchers
      BARE_FIELD    = /\w+:\s?[^'"]{2}\S*/
      QUOTED_FIELD  = /\w+:\s?['"].+?['"]/
      QUOTED_VALUE  = /\A['"](.+)['"]\Z/
      ALL_FIELDS    = /\w+:\s?((['"].+?['"])|([^'"]{2}\S*))/
      BOOLEAN_OR    = /\s+OR\s+/
    end
    
    PAGE_SIZE = 10
    SPHINX_OR = ' | '
    
    def self.find(query, opts={})      
      metadata_store  = Store::MetadataStore.new
      full_text_store = Store::FullTextStore.new
      entry_store     = Store::EntryStore.new
            
      query = Parser.new.parse(query) if query.is_a? String
                  
      fielded_results = metadata_store.find_by_fields(query.fields, opts) if query.has_fields?
      attribute_results = entry_store.find_by_attributes(query.attributes, opts) if query.has_attributes?
      text_results = full_text_store.find(query.text, opts) if query.has_text?
      
      result_sets = [fielded_results, attribute_results, text_results].select {|set| set.present? }
      results = result_sets.flatten
      results = results.select {|doc| result_sets.all? {|set| set.include?(doc) } }.map(&:id).uniq
      
      if query.page
        query.total = results.length
        query.from  = query.page * PAGE_SIZE
        query.to    = query.from + PAGE_SIZE
        results     = results[query.from...query.to]
      end
      
      entry_store.find_all(results)
    end
    
  end
  
end
