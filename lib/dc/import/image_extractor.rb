module DC
  module Import
    
    # The Image Extractor pulls out document thumbnails from a PDF ... later,
    # it may also save each page of the PDF as a JPEG at different zoom levels.
    # Depends on GraphicsMagick (a working gm command).
    class ImageExtractor
            
      attr_reader :thumbnail_path, :large_page_image, :normal_page_image
            
      def initialize(pdf_path)
        @pdf_path             = pdf_path
        @pdf_name             = File.basename(@pdf_path, '.pdf')
        @thumbnail_path       = "#{@pdf_name}_thumb.jpg"
        @normal_page_image    = "#{@pdf_name}_normal.gif"
        @large_page_image     = "#{@pdf_name}_large.gif"
      end
      
      def get_thumbnails
        `gm convert -quality 85 -density 72x72 -scale 60x75   #{@pdf_path}[0] #{@thumbnail_path}`
        self
      end
      
      def get_page_images
        `gm convert -resize 700x -density 220 -depth 8 -unsharp 0.5x0.5+0.5+0.03 #{@pdf_path} #{@normal_page_image}`
        `gm convert -resize 1000x -density 220 -depth 8 -unsharp 0.5x0.5+0.5+0.03 #{@pdf_path} #{@large_page_image}`
        self
      end
      
    end
    
  end
end