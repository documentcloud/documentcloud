module DC
  module Search
    
    # Our first stab at a Search::Parser will just use simple regexs to pull out
    # fielded queries ... so, no nesting.
    #
    # Performs some simple translations to transform standard boolean queries
    # into a form that Sphinx extended2 can understand.
    #
    # Something that might be a little unexpected is the transformation of 
    # any textual queries into "title" attribute queries as well.
    #
    # We should try to adopt Google conventions, if possible, after:
    # http://www.google.com/help/cheatsheet.html
    class Parser
      
      def parse(query_string)
        @text, @fields, @attributes = nil, [], []
        
        bare_fields   = query_string.scan(Matchers::BARE_FIELD)
        quoted_fields = query_string.scan(Matchers::QUOTED_FIELD)
        search_text   = query_string.gsub(Matchers::ALL_FIELDS, '').squeeze(' ').strip
        
        process_search_text(search_text)
        process_fields(bare_fields, quoted_fields)
        
        Query.new(:text => @text, :fields => @fields, :attributes => @attributes)
      end
      
      def process_search_text(text)
        return if text.empty?
        @attributes << Field.new('title', text)
        @text = text.gsub(Matchers::BOOLEAN_OR, SPHINX_OR)
      end
      
      def process_fields(bare, quoted)
        bare.map! {|f| f.split(':') }
        quoted.map! {|f| f.gsub(/['"]/, '').split(':') }
        (bare + quoted).each do |pair| 
          field = Field.new(*pair)
          (field.attribute? ? @attributes : @fields) << field
        end
      end
      
    end
    
  end
end