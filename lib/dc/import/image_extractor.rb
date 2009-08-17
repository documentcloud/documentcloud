module DC
  module Import
    
    # The Image Extractor pulls out document thumbnails from a PDF ... later,
    # it may also save each page of the PDF as a JPEG at different zoom levels.
    # Depends on GraphicsMagick (a working gm command).
    class ImageExtractor
      
      TMP_DIR = File.join(Dir.tmpdir, 'dc_image_extractor')
      
      attr_reader :thumbnail_path, :small_thumbnail_path
            
      def initialize(pdf_path)
        FileUtils.mkdir_p(TMP_DIR) if !File.exists?(TMP_DIR)
        
        @pdf_path             = pdf_path
        @pdf_name             = File.basename(@pdf_path, '.pdf')
        @thumbnail_path       = "#{TMP_DIR}/#{@pdf_name}_thumb.jpg"
        @small_thumbnail_path = "#{TMP_DIR}/#{@pdf_name}_thumb_small.jpg"
      end
      
      def get_thumbnails
        `gm convert -quality 85 -density 72x72 -scale 60x75 #{@pdf_path}[0] #{@thumbnail_path}`
        `gm convert -quality 85 -density 72x72 -scale 24x30 #{@thumbnail_path} #{@small_thumbnail_path}`
      end
      
    end
    
  end
end