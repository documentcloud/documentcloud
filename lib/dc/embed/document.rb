module DC
  module Embed
    class Document < Base
      class Config < Base::Config
        define_attributes do
          string  :container
          number  :default_page,      output_as: :page
          number  :default_note,      output_as: :note
          number  :maxheight,         output_as: :height
          number  :maxwidth,          output_as: :width
          number  :zoom
          boolean :notes,             output_as: :showAnnotations
          boolean :search
          boolean :sidebar
          boolean :text
          boolean :pdf
          boolean :responsive
          number  :responsive_offset, output_as: :responsiveOffset
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
        [:id, :resource_url].each do |attribute| 
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
          @template.location = @template_path
        end
        @template
      end

      def render(data, options)
        template.result(binding)
      end

      def content_markup
        template_options = {
          default_container_id: "DV-viewer-#{@resource.id}",
          resource_url:         @resource.resource_url
        }
        template_options[:generate_default_container] = @embed_config[:container].nil? || @embed_config[:container].empty? || @embed_config[:container] == '#' + template_options[:default_container_id]

        @embed_config[:container] ||= '#' + template_options[:default_container_id]
        render(@embed_config.dump, template_options)
      end

      def bootstrap_markup
        @strategy == :oembed ? inline_loader : static_loader
      end
  
      def inline_loader
        <<-SCRIPT
        <script>
        #{ERB.new(File.read("#{Rails.root}/app/views/documents/oembed_loader.js.erb")).result(binding)}
        </script>
        <script type="text/javascript" src="#{DC.cdn_root(agnostic: true)}/viewer/viewer.js"></script>
        SCRIPT
      end
  
      def static_loader
        %(<script type="text/javascript" src="#{DC.cdn_root(agnostic: true)}/viewer/loader.js"></script>)
      end
  
      # intended for use in the static deployment to s3.
      def self.static_loader(options={})
        template_path = "#{Rails.root}/app/views/documents/embed_loader.js.erb"
        ERB.new(File.read(template_path)).result(binding)
      end
  
      def as_json
        if @strategy == :oembed
          {
            type:          "rich",
            version:       "1.0",
            provider_name: "DocumentCloud",
            provider_url:  DC.server_root(force_ssl: true),
            cache_age:     300,
            height:        @embed_config[:maxheight],
            width:         @embed_config[:maxwidth],
            html:          code,
          }
        else
          @resource.as_json.merge(html: code)
        end
      end
    end
  end
end