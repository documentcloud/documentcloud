module DC
  module Embed
    class Search < Base

      # intended for use in the static deployment to s3.
      def self.static_loader(options={})
        template_path = "#{Rails.root}/app/views/search/embed_loader.js.erb"
        ERB.new(File.read(template_path)).result(binding)
      end
  
    end
  end
end