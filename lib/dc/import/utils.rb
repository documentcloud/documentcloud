module DC
  module Import

    module Utils

      def self.read_ascii(path)
        Iconv.iconv('ascii//translit//ignore', 'utf-8', File.read(path)).first
      end

      def self.save_page_images(asset_store, document, page_number, filename, access)
        images = Page::IMAGE_SIZES.reduce({}) do |sizes, label_size_pair|
          label, size  = label_size_pair
          sizes[label] = "images/#{size}/#{filename}"
          sizes
        end
        asset_store.save_page_images(document, page_number, images, access)
      end

    end

  end
end