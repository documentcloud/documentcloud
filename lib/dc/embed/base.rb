# DC::Embed::Base is the base presenter class
# which is used to transform a request for a resource
# into a serializable set of attributes which represent
# how to embed that resource.

module DC
  module Embed
    class Base
      attr_accessor :strategy, :dom_mechanism, :template
      attr_reader   :resource, :embed_config
      
      CONFIG_KEYS = []
      
      def self.config_keys
        self::CONFIG_KEYS
      end
      
      # Embed presenters accept 
      # a hash representing a resource,
      # configuration which specifies how the embed markup/data will be generated
      # and a set of options specifying how the presenter will behave
      def initialize(resource, embed_config={}, options={})
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