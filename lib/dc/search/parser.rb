module DC
  module Search
    
    # Our first stab at a Search::Parser will just use simple regexs to pull out
    # fielded queries ... so, no nesting.
    # Performs some simple translations to transform standard boolean queries
    # into a form that Sphinx extended2 can understand.
    # We should try to adopt Google conventions, if possible, after:
    # http://www.google.com/help/cheatsheet.html
    class Parser
      
      def parse(query_string)
        bare_fields   = query_string.scan(Matchers::BARE_FIELD)
        quoted_fields = query_string.scan(Matchers::QUOTED_FIELD)
        search_phrase = query_string.gsub(Matchers::ALL_FIELDS, '').squeeze(' ').strip
        
        search_phrase = process_search_phrase(search_phrase)
        fields = process_fields(bare_fields, quoted_fields)
        
        Query.new(:phrase => search_phrase, :fields => fields)
      end
      
      def process_search_phrase(phrase)
        return nil if phrase.empty?
        phrase.gsub(Matchers::BOOLEAN_OR, SPHINX_OR)
      end
      
      def process_fields(bare, quoted)
        bare.map! {|f| f.split(':') }
        quoted.map! {|f| f.gsub(/['"]/, '').split(':') }
        (bare + quoted).map {|pair| Field.new(*pair) }
      end
      
    end
    
  end
end