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
      
      class Config
        Boolean = Proc.new{ |value|
          case
          when (value.kind_of? TrueClass or value.kind_of? FalseClass); then value
          when value == "true"; then true
          when value == "false"; then false
          else; value
          end
        }
    
        Integer = Proc.new { |value|
          case
          when value.kind_of?(Numeric); then value
          when value =~ /\A[+-]?\d+\Z/; then value.to_i
          when value =~ /\A[+-]?\d+\.\d+\Z/; then value.to_f
          else; value
          end
        }
    
        String = Proc.new{ |value| value.to_s unless value.nil? }
    
        ATTRIBUTE_MAP = {}
             
        KEYS = ATTRIBUTE_KEYS = ATTRIBUTE_MAP.keys
    
        NAME_MAP = {}
    
        def self.keys; KEYS; end
        attr_reader *KEYS
        def initialize(args={})
          self.class.keys.each{ |attribute| self[attribute] = args[attribute] }
        end
    
        def attributes
          Hash[self.class.keys.map{ |attribute| [attribute, self[attribute]] }]
        end
    
        def [](attribute); self.instance_variable_get("@#{attribute}"); end
    
        def []=(attribute, value)
          raise ArgumentError unless KEYS.include? attribute
          self.instance_variable_set("@#{attribute}", ATTRIBUTE_MAP[attribute].call(value))
        end
    
        def compact
          self.attributes.delete_if{ |key, value| value.nil? }
        end
    
        def dump
          attribute_pairs = self.compact.map do |attribute, value|
            attribute = NAME_MAP[attribute] if NAME_MAP.keys.include? attribute
            [attribute, value]
          end
          Hash[attribute_pairs]
        end
      end
    end
  end
end