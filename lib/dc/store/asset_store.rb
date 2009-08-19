module DC
  module Store
    
    # The AssetStore is responsible for storing search-opaque document assets, 
    # either on S3 (or in development on the local filesystem in a tmp dir).
    class AssetStore
      include FileUtils
      
      def initialize
        mkdir_p(local_storage_path) unless File.exists?(local_storage_path)
      end
      
      def local_storage_path
        "#{RAILS_ROOT}/tmp/asset_store"
      end
      
      def full_text_path(document)
        "#{local_storage_path}/#{document.id}.txt"
      end
      
      def pdf_path_for(document)
        "#{local_storage_path}/#{document.id}.pdf"
      end
      
      def thumbnail_path_for(document, extension=nil)
        ext = extension ? "_#{extension}" : ''
        "#{local_storage_path}/#{document.id}#{ext}.jpg"
      end
      
      def save_document(document)
        save_pdf(document)
        save_images(document)
        save_full_text(document)
      end
      
      def save_pdf(document)
        doc_path, real_path = document.pdf_path, pdf_path_for(document)
        return if !doc_path || doc_path == real_path
        `curl -s #{doc_path} > #{real_path}`
        # FileUtils.cp doc_path, real_path
        document.pdf_path = real_path
      end
      
      def save_thumbnail(document, extension=nil)
        thumb_path = extension == 'small' ? document.small_thumbnail_path : document.thumbnail_path
        real_path = thumbnail_path_for(document, extension)
        return if !thumb_path || thumb_path == real_path
        `curl -s #{thumb_path} > #{real_path}`
        extension == 'small' ? document.small_thumbnail_path = real_path : document.thumbnail_path = real_path
      end
      
      def save_images(document)
        save_thumbnail(document)
        save_thumbnail(document, 'small')
      end
      
      def save_full_text(document)
        path = full_text_path(document)
        File.open(path, 'w+') {|f| f.write(document.full_text) }
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
      
      # Delete the assets store entirely.
      def delete_database!
        FileUtils.rm_r(local_storage_path) if File.exists?(local_storage_path)
      end
      
    end
    
  end
end