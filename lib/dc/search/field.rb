module DC
  module Search

    class Field

      HAS_WHITESPACE = /\s/

      attr_reader :kind, :value

      def initialize(kind, value)
        @kind, @value = kind.downcase, value.strip
      end

      def attribute?
        Document::SEARCHABLE_ATTRIBUTES.include? @kind.to_sym
      end

      def entity?
        Document::DC::ENTITY_KINDS.include? @kind.to_sym
      end

      def to_s
        val = @value.match(HAS_WHITESPACE) ? "\"#{@value}\"" : @value
        "#{@kind}:#{val}"
      end

      def to_json(opts={})
        {'kind' => kind, 'value' => value}.to_json
      end

    end

  end
end