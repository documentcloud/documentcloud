module DC
  module Embed
    class Base
      attr_accessor :strategy, :dom_mechanism, :template
      attr_reader   :resource, :embed_config
      
      CONFIG_KEYS = []
      
      def self.config_keys
        self::CONFIG_KEYS
      end
      
      def initialize(*args)
        raise NotImplementedError
      end
    
      def bootstrap_markup
        raise NotImplementedError
      end
      
      def content_markup
        raise NotImplementedError
      end
      
      def code
        [bootstrap_markup, content_markup].join("\n")
      end
      
      private
      def content_template
        raise NotImplementedError
      end
      
      def bootstrap_template
        raise NotImplementedError
      end
      
      def render(template, data, options)
        raise NotImplementedError
      end
    end
  end
end