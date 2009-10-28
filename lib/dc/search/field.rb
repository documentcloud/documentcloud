module DC
  module Search
    
    class Field
      
      HAS_WHITESPACE = /\s/
      
      attr_reader :type, :value
      
      def initialize(type, value)
        @type, @value = type.downcase, value.strip
      end
      
      def attribute?
        Document::SEARCHABLE_ATTRIBUTES.include? @type.to_sym
      end
      
      def to_s
        val = @value.match(HAS_WHITESPACE) ? "\"#{@value}\"" : @value
        "#{@type}:#{val}"
      end
      
      def to_json(opts={})
        {'type' => type, 'value' => value}.to_json
      end
      
    end
    
  end
end