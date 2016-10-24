# DC::Embed::Base is the base presenter class
# which is used to transform a request for a resource
# into a serializable set of attributes which represent
# how to embed that resource.

module DC
  module Embed
    class Base
      attr_accessor :strategy, :dom_mechanism, :template
      attr_reader   :resource, :embed_config

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
      
      def self.config_keys
        Config.keys
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

      # Embeds specify the configuration options
      # with subclasses of this Config class.
      class Config
        # Within this class's metaclass
        # we'll define a set of fields and their types
        class << self
          attr_reader :attributes, :attribute_map, :keys 
          
          # set up the hashes we'll use to
          # keep track of the whitelist of attributes
          # and their types
          def define_attributes
            @attributes    = {}
            @attribute_map = {}
            yield # to the user defined block for further instruction
            @keys = @attributes.keys.freeze
            @attribute_map.freeze
            @attributes.freeze
          end
          
          # number, string and boolean methods on
          # our metaclass allow users to instruct
          # the metaclass what fields it should accept
          # and how values for that field should be coerced.
          private
          def number(name, options={})
            attr_reader name
            @attributes[name]    = :number
            @attribute_map[name] = options[:output_as] if options[:output_as]
          end
    
          def string(name, options={})
            attr_reader name
            @attributes[name]    = :string
            @attribute_map[name] = options[:output_as] if options[:output_as]
          end
    
          def boolean(name, options={})
            attr_reader name
            @attributes[name]    = :boolean
            @attribute_map[name] = options[:output_as] if options[:output_as]
          end
        end
        
        # coerce values according to the type of their field
        def coerce(value, field_name)
          type = self.class.attributes[field_name]
          case type
          when :boolean
            case
            when (value.kind_of? TrueClass or value.kind_of? FalseClass); then value
            when value == "true"; then true
            when value == "false"; then false
            else; value
            end
          when :number
            case
            when value.kind_of?(Numeric); then value
            when value =~ /\A[+-]?\d+\Z/; then value.to_i
            when value =~ /\A[+-]?\d+\.\d+\Z/; then value.to_f
            else; value
            end
          when :string
            value.to_s unless value.nil?
          else
            raise ArgumentError, "#{type} isn't supported as a configuration key type."
          end
        end
        
        # When initializing search the input arguments for fields which
        # this configuration class accepts
        def initialize(args={})
          self.class.keys.each{ |attribute| self[attribute] = args[attribute] }
        end
        
        # store attributes as instance variables
        def []=(attribute, value)
          raise ArgumentError unless self.class.keys.include? attribute
          # coerce value according to its attribute's type before being set.
          self.instance_variable_set("@#{attribute}", coerce(value, attribute))
        end
        
        def [](attribute); self.instance_variable_get("@#{attribute}"); end
        
        def attributes
          Hash[self.class.keys.map{ |attribute| [attribute, self[attribute]] }]
        end
        
        def compact
          self.attributes.delete_if{ |key, value| value.nil? }
        end
        
        def dump
          attribute_pairs = self.compact.map do |attribute, value|
            # replace input keys with output keys as specified
            attribute = self.class.attribute_map[attribute] if self.class.attribute_map.keys.include? attribute
            [attribute, value]
          end
          Hash[attribute_pairs]
        end
      end
    end
  end
end
