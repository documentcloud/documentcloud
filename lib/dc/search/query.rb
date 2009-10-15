module DC
  module Search
    
    class Query
      
      attr_reader   :text, :fields, :attributes
      attr_accessor :page, :from, :to, :total
      
      def initialize(opts={})
        @text       = opts[:text]
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
        instance_variables.inject({}) do |memo, var| 
          memo[var[1..-1]] = instance_variable_get(var)
          memo
        end
      end
      
    end
    
  end
end