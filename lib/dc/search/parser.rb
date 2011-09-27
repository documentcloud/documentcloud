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
      include DC::Access

      # Parse a raw query_string, returning a DC::Search::Query that knows
      # about the text, fields, projects, and attributes it's composed of.
      def parse(query_string='')
        @text, @access, @source_document = nil, nil, nil
        @fields, @accounts, @groups, @projects, @project_ids, @doc_ids, @attributes, @filters, @data =
          [], [], [], [], [], [], [], [], []

        fields        = query_string.scan(Matchers::FIELD).map {|m| [m[0], m[3]] }
        search_text   = query_string.gsub(Matchers::FIELD, '').squeeze(' ').strip

        @text = search_text.present? ? search_text : nil
        process_fields_and_projects(fields)

        Query.new(:text => @text, :fields => @fields, :projects => @projects,
          :accounts => @accounts, :groups => @groups, :project_ids => @project_ids,
          :doc_ids => @doc_ids, :attributes => @attributes, :access => @access,
          :filters => @filters, :data => @data, :source_document => @source_document)
      end

      # Extract the portions of the query that are fields, attributes,
      # and projects.
      def process_fields_and_projects(fields)
        fields.each do |pair|
          type  = pair.first.gsub(/(^['"]|['"]$)/, '')
          value = pair.last.gsub(/(^['"]|['"]$)/, '')
          case type.downcase
          when 'account'    then @accounts << value.to_i
          when 'group'      then @groups << value.downcase
          when 'filter'     then @filters << value.downcase.to_sym
          when 'access'     then @access = ACCESS_MAP[value.strip.to_sym]
          when 'project'    then @projects << value
          when 'projectid'  then @project_ids << value.to_i
          when 'document'   then @doc_ids << value.to_i
          when 'related'    then @source_document = Document.find(value.to_i)
          else
            process_field(type, value)
          end
        end
      end

      # Convert an individual field or attribute search into a DC::Search::Field.
      def process_field(kind, value)
        field = Field.new(match_kind(kind), value.strip)
        return @attributes << field if field.attribute?
        return @fields     << field if field.entity?
        return @data       << field
      end

      # Convert a field kind string into its canonical form, by searching
      # through all the valid kinds for a match.
      def match_kind(kind)
        DC::VALID_KINDS.detect {|s| s.match(Regexp.new(kind.downcase)) } || kind
      end

    end

  end
end