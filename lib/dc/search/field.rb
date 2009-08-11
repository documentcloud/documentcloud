module DC
  module Search
    
    class Field
      
      attr_reader :type, :value
      
      def initialize(type, value)
        @type, @value = type, value.strip
      end
      
    end
    
  end
end