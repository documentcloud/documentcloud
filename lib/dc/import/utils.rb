module DC
  module Import

    module Utils

      def read_ascii(path)
        Iconv.iconv('ascii//translit//ignore', 'utf-8', File.read(path)).first
      end

      def save_page_images(document, page_number, filename, access)
        asset_store.save_page_images(document, page_number,
          {'normal'     => "images/700x/#{filename}",
           'small'      => "images/180x/#{filename}",
           'large'      => "images/1000x/#{filename}",
           'small'      => "images/180x/#{filename}",
           'thumbnail'  => "images/60x75!/#{filename}"},
          access
        )
      end

    end

  end
end