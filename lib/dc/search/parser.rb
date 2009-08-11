module DC
  module Search
    
    # Our first stab at a Search::Parser will just use simple regexs to pull out
    # fielded queries ... so, no nesting.
    class Parser
      
      BARE_FIELD_MATCHER    = /\w+:\s?[^'"]{2}\S*/
      QUOTED_FIELD_MATCHER  = /\w+:\s?['"].+?['"]/
      ALL_FIELDS_MATCHER    = /\w+:\s?((['"].+?['"])|([^'"]{2}\S*))/
      
      def parse(query_string)
        bare_fields   = query_string.scan(BARE_FIELD_MATCHER)
        quoted_fields = query_string.scan(QUOTED_FIELD_MATCHER)
        search_phrase = query_string.gsub(ALL_FIELDS_MATCHER, '').squeeze(' ').strip
        
        search_phrase = nil if search_phrase.empty?
        bare_fields.map! {|f| f.split(':') }
        quoted_fields.map! {|f| f.gsub(/['"]/, '').split(':') }
        fields = (bare_fields + quoted_fields).map {|pair| Field.new(*pair) }
        
        Query.new(:phrase => search_phrase, :fields => fields)
      end
      
    end
    
  end
end