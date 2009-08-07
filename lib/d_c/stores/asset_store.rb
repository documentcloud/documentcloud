module DC
  module Stores
    
    # The AssetStore is responsible for storing search-opaque document assets, 
    # either on S3 (or in development on the local filesystem in /tmp).
    class AssetStore
      
      def initialize
        
      end
      
      def save_document(document)
        save_pdf(document)
        save_images(document)
      end
      
      def save_pdf(document)
        @store.save(document.pdf.path, document.pdf.contents)
      end
      
      def save_images(document)
        document.images.each {|image| save_image(image) }
      end
      
      def save_image(image)
        @store.save(image.path, image.contents)
      end
      
      def find_pdf(pdf)
        DC::PDF.new(@store.find(pdf.path))
      end
      
      def find_images(document)
        document.images.map {|image| find_image(image) }
      end
      
      def find_image(image)
        DC::Image.new(@store.find(image.path))
      end
      
    end
    
  end
end