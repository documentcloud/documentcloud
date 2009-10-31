module DC
  module Search
    
    # Our first stab at a Search::Parser will just use simple regexs to pull out
    # fielded queries ... so, no nesting.
    #
    # Performs some simple translations to transform standard boolean queries
    # into a form that Sphinx extended2 can understand.
    #
    # We should try to adopt Google conventions, if possible, after:
    # http://www.google.com/help/cheatsheet.html
    class Parser
      
      def parse(query_string)
        @text, @fields, @labels, @attributes = nil, [], [], []
        
        bare_fields   = query_string.scan(Matchers::BARE_FIELD)
        quoted_fields = query_string.scan(Matchers::QUOTED_FIELD)
        search_text   = query_string.gsub(Matchers::ALL_FIELDS, '').squeeze(' ').strip
        
        process_search_text(search_text)
        process_fields_and_labels(bare_fields, quoted_fields)
        
        Query.new(:text => @text, :fields => @fields, :labels => @labels, :attributes => @attributes)
      end
      
      def process_search_text(text)
        return if text.empty?
        # Something that might be a little unexpected is the transformation of 
        # any textual queries into "title" attribute queries as well.
        # @attributes << Field.new('title', text)
        @text = text.gsub(Matchers::BOOLEAN_OR, SPHINX_OR)
      end
      
      def process_fields_and_labels(bare, quoted)
        bare.map! {|f| f.split(':') }
        quoted.map! {|f| f.gsub(/['"]/, '').split(/:\s*/) }
        (bare + quoted).each do |pair|
          type, value = *pair
          type.downcase == 'label' ? process_label(value) : process_field(type, value)
        end
      end
      
      def process_field(kind, value)
        field = Field.new(match_kind(kind), value.strip)
        (field.attribute? ? @attributes : @fields) << field
      end

      def process_label(title)
        @labels << title.strip
      end
      
      def match_kind(kind)
        matcher = Regexp.new(kind.downcase)
        DC::VALID_KINDS.detect {|canonical| canonical.match(matcher) }
      end
      
    end
    
  end
end