module DC
  module Search
    
    class Query
      
      attr_reader :text, :fields, :attributes
      
      def initialize(opts={})
        @text       = opts[:text]
        @naked_text = @text && @text.sub(Matchers::QUOTED_VALUE, '\1')
        @fields     = opts[:fields] || []
        @attributes = opts[:attributes] || []
      end
      
      def has_fields?;      @fields.present?;       end      
      def has_text?;        @text.present?;         end
      def has_attributes?;  @attributes.present?;   end
      
      def inspect
        text        = @text ? "\"#{@text}\"" : ''
        fields      = @fields.map(&:to_s).join(' ')
        attributes  = @attributes.map(&:to_s).join(' ')
        "#<DC::Search::Query #{text} #{attributes} #{fields}>"
      end
      
      def as_json(opts={})
        {
          'text'        => @text,
          'fields'      => @fields,
          'attributes'  => @attributes
        }
      end
      
    end
    
  end
end