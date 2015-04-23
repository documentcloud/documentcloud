module DC
  module Embed
    class Document < Base
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
    
        ATTRIBUTE_MAP = {
          :container         => self::String,
          :default_page      => self::Integer,
          :default_note      => self::Integer,
          :maxheight         => self::Integer,
          :maxwidth          => self::Integer,
          :zoom              => self::Integer,
          :notes             => self::Boolean,
          :search            => self::Boolean,
          :sidebar           => self::Boolean,
          :text              => self::Boolean,
          :pdf               => self::Boolean,
          :responsive        => self::Boolean,
          :responsive_offset => self::Integer, }
             
        KEYS = ATTRIBUTE_KEYS = ATTRIBUTE_MAP.keys
    
        NAME_MAP = {
          :notes             => :showAnnotations,
          :responsive_offset => :responsiveOffset,
          :default_page      => :page,
          :default_note      => :note,
          :maxheight         => :height,
          :maxwidth          => :width,
        }
    
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
  
      def self.config_keys
        Config.keys
      end
  
      def initialize(resource, embed_config={}, options={})
        # resource should be a wrapper object around a model 
        # which plucks out relevant metadata
        # Consider ActiveModel::Serializers for this purpose.
        # N.B. we should be able to generate oembed codes for things that are 
        # basically mocks of a document, not just for real documents
        [:id, :js_url].each do |attribute| 
          raise ArgumentError, "Embed resource must `respond_to?` an ':#{attribute}' attribute" unless resource.respond_to?(attribute)
        end
        @resource      = resource
        @embed_config  = Config.new(embed_config)
        @strategy      = options[:strategy]      || :literal # :oembed is the other option.
        @dom_mechanism = options[:dom_mechanism] || :direct

        @template_path = options[:template_path] || "#{Rails.root}/app/views/documents/_embed_code.html.erb"
        @template      = options[:template]
      end

      def template
        unless @template
          @template = ERB.new(File.read(@template_path))
          #@template.location = @template_path # uncomment this once deployed onto Ruby 2.2
        end
        @template
      end

      def render(data, options)
        template.result(binding)
      end

      def content_markup
        template_options = {
          :use_default_container => @embed_config[:container].nil? || @embed_config[:container].empty?,
          :default_container_id  => "DV-viewer-#{@resource.id}",
          :resource_js_url       => @resource.js_url
        }
    
        @embed_config[:container] ||= '#' + template_options[:default_container_id]
        render(@embed_config.dump, template_options)
      end

      def bootstrap_markup
        @strategy == :oembed ? inline_loader : static_loader
      end
  
      def inline_loader
        asset_root = DC.cdn_root(:agnostic => true)
        <<-SCRIPT
        <script>
        #{ERB.new(File.read("#{Rails.root}/app/views/documents/oembed_loader.js.erb")).result(binding)}
        </script>
        <script type="text/javascript" src="#{asset_root}/viewer/viewer.js"></script>
        SCRIPT
      end
  
      def static_loader
        %(<script type="text/javascript" src="#{DC.cdn_root(:agnostic => true)}/viewer/loader.js"></script>)
      end
  
      # intended for use in the static deployment to s3.
      def self.static_loader(options={})
        template_path = "#{Rails.root}/app/views/documents/loader.js.erb"
        ERB.new(File.read(template_path)).result(binding)
      end
  
      def as_json
        if @strategy == :oembed
          {
            :type             => "rich",
            :version          => "1.0",
            :provider_name    => "DocumentCloud",
            :provider_url     => DC.server_root(:force_ssl => true),
            :cache_age        => 300,
            :height           => @embed_config[:maxheight],
            :width            => @embed_config[:maxwidth],
            :html             => code,
          }
        else
          @resource.as_json.merge(:html => code)
        end
      end
    end
  end
end