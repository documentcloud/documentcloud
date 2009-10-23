module DC
  module Search
    
    # A Search::Query is almost a struct, holding all the segregated components
    # that can go into a single document search.
    class Query
      
      attr_reader   :text, :fields, :labels, :attributes
      attr_accessor :page, :from, :to, :total
      
      def initialize(opts={})
        @text       = opts[:text]
        @fields     = opts[:fields] || []
        @labels     = opts[:labels] || []
        @attributes = opts[:attributes] || []
      end
      
      # Series of attribute checks to determine the type of query.
    
      def has_text?;        @text.present?;         end
      def has_fields?;      @fields.present?;       end
      def has_labels?;      @labels.present?;       end      
      def has_attributes?;  @attributes.present?;   end
      
      # The json representation of a Search::Query includes all the instance
      # variables.
      def as_json(opts={})
        instance_variables.inject({}) do |memo, var| 
          memo[var[1..-1]] = instance_variable_get(var)
          memo
        end
      end
      
    end
    
  end
end