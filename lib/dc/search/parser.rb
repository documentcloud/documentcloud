module DC
  module Search

    # Our first stab at a Search::Parser will just use simple regexs to pull out
    # fielded queries ... so, no nesting.
    #
    # All the regex matchers live in the Search module.
    #
    # We should try to adopt Google conventions, if possible, after:
    # http://www.google.com/help/cheatsheet.html
    class Parser

      # Parse a raw query_string, returning a DC::Search::Query that knows
      # about the text, fields, projects, and attributes it's composed of.
      def parse(query_string='')
        @text, @fields, @projects, @attributes = nil, [], [], []

        quoted_fields = query_string.scan(Matchers::QUOTED_FIELD).map {|m| m[0] }
        bare_fields   = query_string.gsub(Matchers::QUOTED_FIELD, '').scan(Matchers::BARE_FIELD)
        search_text   = query_string.gsub(Matchers::ALL_FIELDS, '').squeeze(' ').strip

        process_search_text(search_text)
        process_fields_and_projects(bare_fields, quoted_fields)

        SolrQuery.new(:text => @text, :fields => @fields, :projects => @projects, :attributes => @attributes)
      end

      # Convert the full-text search into a form that our index can handle.
      def process_search_text(text)
        return if text.empty?
        @text = text.gsub(Matchers::BOOLEAN_OR, QUERY_OR)
      end

      # Extract the portions of the query that are fields, attributes,
      # and projects.
      def process_fields_and_projects(bare, quoted)
        bare.map! {|f| f.split(/:\s*/) }
        quoted.map! do |f|
          type  = f.match(/(.+?):\s*/)[1]
          value = f.sub(/(.+?):\s*/, '').gsub(/(^['"]|['"]$)/, '')
          [type, value]
        end
        (bare + quoted).each do |pair|
          type, value = *pair
          type.downcase == 'project' ? process_project(value) : process_field(type, value)
        end
      end

      # Convert an individual field or attribute search into a DC::Search::Field.
      def process_field(kind, value)
        field = Field.new(match_kind(kind), value.strip)
        return @attributes << field if field.attribute?
        return @fields     << field if field.entity?
        @text ||= ''
        @text += " #{field}"
      end

      # Convert an individual project search.
      def process_project(title)
        @projects << title.strip
      end

      # Convert a field kind string into its canonical form, by searching
      # through all the valid kinds for a match.
      def match_kind(kind)
        matcher = Regexp.new(kind.downcase)
        DC::VALID_KINDS.detect {|canonical| canonical.match(matcher) } || kind
      end

    end

  end
end