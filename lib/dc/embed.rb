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

## Strategy

Embed strategy is the manner in which the embed code is introduced to the web page it has been instructed to load on (either contained in the markup sent to the browser, or inserted dynamically via javascript).

* Embedded in markup (server_side)
* Client-side injection (client_side)

=end
module DC
  class Embed
    attr_accessor :strategy, :dom_mechanism
    attr_reader   :resource, :config
    
    def initialize(resource, config, options={})
      # resource should be a wrapper object around a model 
      # which plucks out relevant metadata
      # Consider ActiveModel::Serializers for this purpose.
      # N.B. we should be able to generate oembed codes for things that are 
      # basically mocks of a document, not just for real documents
      [:id, :url].each do |attribute| 
        raise ArgumentError, "Embed resource must `respond_to?` an ':#{attribute}' attribute" unless resource.respond_to?(attribute)
      end
      @resource      = resource
      @config        = config # probably just a hash.
      @strategy      = options[:strategy]      || :server_side
      @dom_mechanism = options[:dom_mechanism] || :direct
    end
    
    def content_markup
      template_options = {
        :use_default_container => @config[:container].nil? || @config[:container].empty?,
        :default_container_id  => "DV-viewer-#{@resource.id}",
        :resource_js_url       => url_for(resource_params.merge(:format => 'js'))
      }
      embed_data = {
        :container        => params[:container]         || template_options[:default_container_id],
        :zoom             => params[:zoom]              || nil,
        :search           => params[:search]            || nil,
        :showAnnotations  => params[:notes]             || nil,
        :sidebar          => params[:sidebar]           || nil,
        :text             => params[:text]              || nil,
        :pdf              => params[:pdf]               || nil,
        :responsive       => params[:responsive]        || nil,
        :responsiveOffset => params[:responsive_offset] || nil,
        :page             => params[:default_page]      || nil,
        :note             => params[:default_note]      || nil,
        :height           => params[:maxheight]         || nil,
        :width            => params[:maxwidth]          || nil,
      }
      embed_data = Hash[embed_data.reject { |k, v| v.nil? }]

      ERB.new(File.read("#{Rails.root}/app/views/documents/_embed_code.html.erb")).result(binding)
    end
    
    def bootstrap_markup
      '<script src="//s3.amazonaws.com/s3.documentcloud.org/viewer/loader.js"></script>'
    end
    
    def code
      [bootstrap_markup, content_markup].join("\n")
    end
  end
end
