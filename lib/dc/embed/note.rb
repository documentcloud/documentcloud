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
        @strategy      = options[:strategy]      || :literal # or :oembed
        @dom_mechanism = options[:dom_mechanism] || :iframe  # or :direct
        config_options = (@dom_mechanism == :iframe ? {map_keys: false} : {map_keys: true}).merge(options)
        @embed_config  = Config.new(data: embed_config, options: config_options)

        @template_path = options[:template_path] || "#{Rails.root}/app/views/annotations/_#{@dom_mechanism}_embed_code.html.erb"
        @template      = options[:template]

        @note = ::Annotation.find @resource.id
      end

      def accessible?
        @note.public?
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

      def code
        if @dom_mechanism == :direct
          [bootstrap_markup, content_markup].join("\n").squish
        else
          content_markup.squish
        end
      end

      def content_markup
        template_options = {
          resource_url: @resource.resource_url,
          note:         @note,
        }

        if @dom_mechanism == :direct
          template_options[:default_container_id] = "DC-note-#{@resource.id}"
          template_options[:generate_default_container] = !@embed_config[:container].present? || @embed_config[:container] == '#' + template_options[:default_container_id]
          @embed_config[:container] ||= '#' + template_options[:default_container_id]
        end

        render(@embed_config.dump, template_options)
      end

      def bootstrap_markup
        # TODO: Investigate if we actually need to make this distinction [JR]
        @strategy == :oembed ? inline_loader : static_loader
      end

      def inline_loader
        <<-SCRIPT
        <script>
          #{ERB.new(File.read("#{Rails.root}/app/views/annotations/embed_loader.js.erb")).result(binding)}
        </script>
        SCRIPT
      end

      def static_loader
        %(<script type="text/javascript" src="#{DC.asset_root(agnostic: true)}/notes/loader.js"></script>)
      end

      # intended for use in the static deployment to s3.
      def self.static_loader(options={})
        template_path = "#{Rails.root}/app/views/annotations/embed_loader.js.erb"
        ERB.new(File.read(template_path)).result(binding)
      end

      def as_json
        if @strategy == :oembed
          calculate_dimensions
          {
            type:          "rich",
            version:       "1.0",
            provider_name: "DocumentCloud",
            provider_url:  DC.server_root(force_ssl: true),
            cache_age:     300,
            height:        @dimensions[:height],
            width:         @dimensions[:width],
            html:          code,
          }
        else
          @resource.as_json.merge(html: code)
        end
      end

      # These won't be accurate, since this is the note image area only. Still, 
      # gives the oEmbed response *some* sense of the scale and aspect ratio.
      def calculate_dimensions
        embed_dimensions = @note.embed_dimensions
        @dimensions = {
          height: @embed_config[:maxheight] || (@embed_config[:maxwidth]  ? (@embed_config[:maxwidth]  / embed_dimensions[:aspect_ratio]).round : embed_dimensions[:height_pixel]),
          width:  @embed_config[:maxwidth]  || (@embed_config[:maxheight] ? (@embed_config[:maxheight] * embed_dimensions[:aspect_ratio]).round : embed_dimensions[:width_pixel])
        }
      end

    end
  end
end