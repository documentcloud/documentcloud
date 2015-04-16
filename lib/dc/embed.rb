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

    def self.code(resource, config)
      resource_type = case
      when EMBEDDABLE_MODELS.any?{ |model_klass| resource.kind_of? model_klass }
        EMBEDDABLE_MODEL_MAP[resource.class]
      when EMBEDDABLE_RESOURCES.any?{ |embeddable_resource| resource.type == embeddable_resource }
        resource.type
      else
        # set up a system to actually register types of things as embeddable
        raise ArgumentError, "#{resource} is not registered as an embeddable resource"
      end
      embed_klass = EMBED_RESOURCE_MAP[resource_type]
      embed_klass.new(resource, config).code
    end
    
    class Base
      attr_accessor :strategy, :dom_mechanism, :template
      attr_reader   :resource, :embed_config
      
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
        @strategy      = options[:strategy]      || :server_side
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
          :showAnnotations  => @embed_config[:notes]             || nil,
          :responsiveOffset => @embed_config[:responsive_offset] || nil,
          :page             => @embed_config[:default_page]      || nil,
          :note             => @embed_config[:default_note]      || nil,
          :height           => @embed_config[:maxheight]         || nil,
          :width            => @embed_config[:maxwidth]          || nil,
          # all of the options below are passthrough.
          :zoom             => @embed_config[:zoom]              || nil,
          :search           => @embed_config[:search]            || nil,
          :sidebar          => @embed_config[:sidebar]           || nil,
          :text             => @embed_config[:text]              || nil,
          :pdf              => @embed_config[:pdf]               || nil,
          :responsive       => @embed_config[:responsive]        || nil,
        }
        embed_data = Hash[embed_data.reject { |k, v| v.nil? }]
      
        render(embed_data, template_options)
      end
    
      def bootstrap_markup
        '<script src="//s3.amazonaws.com/s3.documentcloud.org/viewer/loader.js"></script>'
      end
    
      def code
        [bootstrap_markup, content_markup].join("\n")
      end
    end
  
    class DocumentOEmbed < Document
      def bootstrap_markup
        @bootstrap_template_path = "#{Rails.root}/app/views/documents/loader.js.erb"
        @bootstrap_template = ERB.new(File.read(@bootstrap_template_path))
        #@template.location = @template_path # uncomment this once deployed onto Ruby 2.2
        "<script>#{@bootstrap_template.result(binding)}</script>"
      end
    
      def as_json
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
      end
    end
  end
end
