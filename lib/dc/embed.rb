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
      CONFIG_KEYS = [:default_page, :default_note, 
                     :maxheight, :maxwidth, :zoom, 
                     :notes, :search, :sidebar, :text, :pdf, 
                     :responsive, :responsive_offset]
      
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
        @embed_config  = embed_config
        @strategy      = options[:strategy]      || :literal
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
        embed_data = {
          :container        => '#' + (@embed_config[:container]  || template_options[:default_container_id]),
          :showAnnotations  => @embed_config.fetch(:notes,              nil),
          :responsiveOffset => @embed_config.fetch(:responsive_offset,  nil),
          :page             => @embed_config.fetch(:default_page,       nil),
          :note             => @embed_config.fetch(:default_note,       nil),
          :height           => @embed_config.fetch(:maxheight,          nil),
          :width            => @embed_config.fetch(:maxwidth,           nil),
          # all of the options below are passthrough.
          :zoom             => @embed_config.fetch(:zoom,       nil),
          :search           => @embed_config.fetch(:search,     nil),
          :sidebar          => @embed_config.fetch(:sidebar,    nil),
          :text             => @embed_config.fetch(:text,       nil),
          :pdf              => @embed_config.fetch(:pdf,        nil),
          :responsive       => @embed_config.fetch(:responsive, nil),
        }
        embed_data = Hash[embed_data.reject { |k, v| v.nil? }]
      
        render(embed_data, template_options)
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
