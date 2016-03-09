module DC
  module Embed
    class Page < Base
      class Config < Base::Config
        define_attributes do
          number  :maxheight,      output_as: :height
          number  :maxwidth,       output_as: :width
          boolean :credit
          boolean :page_navigator, output_as: :pageNavigator
          boolean :text
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

        @template_path = options[:template_path] || "#{Rails.root}/app/views/pages/_embed_code.html.erb"
        @template      = options[:template]

        # Fetch page from database to populate embed code with page/doc data.
        # `resource_params` were already recognized in `ApiController#oembed`, 
        # but unless we want to pass them to this method, we gotta do it again.
        resource_params = Rails.application.routes.recognize_path(resource.resource_url) rescue nil
        document_id     = resource.id[/^[0-9]+/]
        page_number     = resource_params[:page_number]
        @page           = ::Page.where(document_id: document_id, page_number: page_number).first
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

      # TODO: Consider how page embed works (HTML + enhancer), and customize 
      # `content_markup` and `bootstrap_markup` accordingly. See 
      # `DC::Embed::Base#code`

      # Page embed uses a noscript-style enhancer, which prefers content markup 
      # before bootstrap markup
      def code
        content_markup.squish
      end

      def content_markup
        template_options = {
          resource_url: @resource.resource_url,
          page:         @page,
          document:     @page.document,
        }

        render(@embed_config.dump, template_options)
      end

      def bootstrap_markup
        @strategy == :oembed ? inline_loader : static_loader
      end
  
      def inline_loader
        <<-SCRIPT
        <script>
          #{ERB.new(File.read("#{Rails.root}/app/views/embed/enhance.js.erb")).result(binding)}
        </script>
        SCRIPT
      end
  
      def static_loader
        %(<script type="text/javascript" src="#{DC.cdn_root(agnostic: true)}/embed/loader/enhance.js"></script>)
      end

      # intended for use in the static deployment to s3.
      def self.static_loader(options={})
        template_path = "#{Rails.root}/app/views/embed/enhance.js.erb"
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