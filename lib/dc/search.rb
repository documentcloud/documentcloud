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
      query = Parser.new.parse(query) if query.is_a? String
      query.run
    end
    
  end
  
end
