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
      results = results.select {|doc| result_sets.all? {|set| set.include?(doc) } }
      entry_store.find_all(results.map {|doc| doc.id })
      
      # FIXME: Uniq isn't working, despite implementing Document#hash and 
      # Document#eql?, so hash it ourselves for now.
      # docs = results.inject({}) {|h, doc| h[doc.id] = doc; h}.values
    end
    
  end
  
end
