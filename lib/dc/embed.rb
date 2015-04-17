=begin

# Thoughts

Embeds can be categorized along three dimensions:

## Resource

The resource is the type of thing you are embedding.  The contents of the embed will depend on the resource.  Each resource will include different code and configuration options (the literal contents of the embed). 

* Documents
* Notes
* Search

## DOM Mechanism

The mechanism used for containing the contents of an embed.  Effectively there are two types of mechanisms: inserting a JS application directly into the embedding DOM, or inserting an iFrame which contains the contents of the embed.

* in-DOM (direct)
* iFrame

## Embedding Context

Embedding context is the manner in which the embed code is introduced to the web page it 
has been instructed to load on (either contained in the markup sent to the browser, or 
inserted dynamically via javascript).

The embedding context is generally not known to the embed generator.

* Embedded in markup (server_side)
* Client-side injection (client_side)

## Request Strategy

* oEmbed
* Literal

=end
module DC
  module Embed
    
    # lol forward declaration
    class Base; end
    class Document < Base; end
    class Note < Base; end
    class Search < Base; end
    EMBED_RESOURCE_MAP = {
      :document => self::Document,
      :note     => self::Note,
      :search   => self::Search,
    }
    EMBEDDABLE_RESOURCES = EMBED_RESOURCE_MAP.keys
    
    EMBEDDABLE_MODEL_MAP = {
      ::Document   => :document,
      ::Annotation => :note,
    }
    EMBEDDABLE_MODELS = EMBEDDABLE_MODEL_MAP.keys
    
    def self.embed_type(resource)
      case
      when EMBEDDABLE_MODELS.any?{ |model_klass| resource.kind_of? model_klass }
        EMBEDDABLE_MODEL_MAP[resource.class]
      when EMBEDDABLE_RESOURCES.include?(resource.type)
        resource.type
      else
        # set up a system to actually register types of things as embeddable
        raise ArgumentError, "#{resource} is not registered as an embeddable resource"
      end
    end
    
    def self.embed_klass(type)
      raise ArgumentError, "#{type} is not a recognized resource type" unless EMBEDDABLE_RESOURCES.include? type
      EMBED_RESOURCE_MAP[type]
    end
    
    def self.embed_for(resource, config={}, options={})
      self.embed_klass(self.embed_type(resource)).new(resource, config, options)
    end

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
        [:id, :url].each do |attribute| 
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
          :resource_js_url       => @resource.url
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
          (function() {
            /* If the viewer is already loaded, don't repeat the process. */
            if (window.DV) { if (window.DV.loaded) { return; } }

            window.DV = window.DV || {};
            window.DV.recordHit = "#{DC.server_root(:agnostic=>true)}/pixel.gif";
            
            var pendingQueue = window.DV._documentsWaitingForAppLoad = [];
            window.DV.load = function(resource, options) {
              pendingQueue.push({url: resource, options: options});
            };
            
            var eventuallyLoadDocuments = function(){
              if (window.DV.viewers) {
                for (var i=0; i<pendingQueue.length; i++){ 
                  resource = pendingQueue[i];
                  DV.load(resource.url, resource.options);
                }
              } else {
                setTimeout(eventuallyLoadDocuments, 500);
              }
            };
            eventuallyLoadDocuments();

            var loadCSS = function(url, media) {
              var link   = document.createElement('link');
              link.rel   = 'stylesheet';
              link.type  = 'text/css';
              link.media = media || 'screen';
              link.href  = url;
              var head   = document.getElementsByTagName('head')[0];
              head.appendChild(link);
            };

            /*@cc_on
            /*@if (@_jscript_version < 5.8)
              loadCSS("#{asset_root}/viewer/viewer.css");
            @else @*/
              loadCSS("#{asset_root}/viewer/viewer-datauri.css");
            /*@end
            @*/
            loadCSS("#{asset_root}/viewer/printviewer.css", 'print');

            /* Record the fact that the viewer is loaded. */
            DV.loaded = true;
          })();
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
            :provider_url     => DC.server_root,
            :cache_age        => 300,
            :resource_url     => nil,
            :height           => @embed_config[:maxheight],
            :width            => @embed_config[:maxwidth],
            :display_language => nil,
            :html             => code,
          }
        else
          @resource.as_json.merge(:html => code)
        end
      end
    end
  end
end
