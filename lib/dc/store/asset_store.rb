module DC
  module Store
    
    # The AssetStore is responsible for storing search-opaque document assets, 
    # either on S3 (or in development on the local filesystem in /tmp).
    class AssetStore
      include FileUtils
      
      def initialize
        mkdir_p(local_storage_path) unless File.exists?(local_storage_path)
      end
      
      def local_storage_path
        "/tmp/document_cloud"
      end
      
      def full_text_path(document)
        "#{local_storage_path}/#{document.id}.txt"
      end
      
      def save_document(document)
        save_pdf(document)
        save_images(document)
        save_full_text(document)
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
      
      def save_full_text(document)
        path = full_text_path(document)
        File.open(path, 'w+') {|f| f.write(document.full_text) }
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
      
      def find_full_text(document)
        File.read(full_text_path(document))
      end
      
    end
    
  end
end