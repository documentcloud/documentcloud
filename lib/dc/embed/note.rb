module DC
  module Embed
    class Note < Base
      class Config < Base::Config
        define_attributes do
          string  :container
          number  :maxheight
          number  :maxwidth
        end
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

        @template_path = options[:template_path] || "#{Rails.root}/app/views/annotations/_embed_code.html.erb"
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
          :default_container_id  => "DC-note-#{@resource.id}",
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
          (function() {
            /* If the note embed is already loaded, don't repeat the process. */
            if (window.dc) { if (window.dc.noteEmbedLoaded) { return; } }

            window.dc = window.dc || {};
            window.dc.recordHit = "#{DC.server_root(:agnostic=>true)}/pixel.gif";
        
            var pendingQueue = window.dc._notesWaitingForAppLoad = [];
            window.dc.load = function(resource_js_url, options) {
              pendingQueue.push({js_url: resource_js_url, options: options});
            };
        
            var eventuallyLoadNotes = function(){
              if (window.dc.embed) {
                for (var i=0; i < pendingQueue.length; i++){ 
                  var resource = pendingQueue[i];
                  dc.embed.loadNote(resource.js_url, resource.options);
                }
              } else {
                setTimeout(eventuallyLoadNotes, 500);
              }
            };
            eventuallyLoadNotes();

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
              loadCSS("#{asset_root}/note_embed/note_embed.css");
            @else @*/
              loadCSS("#{asset_root}/note_embed/note_embed-datauri.css");
            /*@end
            @*/

            /* Record the fact that the note embed is loaded. */
            dc.noteEmbedLoaded = true;
          })();
        </script>
        <script type="text/javascript" src="#{asset_root}/note_embed/note_embed.js"></script>
        SCRIPT
      end
  
      def static_loader
        %(<script type="text/javascript" src="#{DC.cdn_root(:agnostic => true)}/notes/loader.js"></script>)
      end
  
      # intended for use in the static deployment to s3.
      def self.static_loader(options={})
        template_path = "#{Rails.root}/app/views/annotations/embed_loader.js.erb"
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