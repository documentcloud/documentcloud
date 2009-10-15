module DC
  module Store
    
    # An implementation of an AssetStore.
    module FileSystemStore
      
      def initialize
        FileUtils.mkdir_p(local_storage_path) unless File.exists?(local_storage_path)
      end
      
      def save(document)
        save_pdf(document)
        save_images(document)
        save_full_text(document)
      end
      
      def full_text_for(document)
        File.read(full_text_path_for(document))
      end
      
      def destroy(document)
        paths = []
        paths << pdf_path_for(document)
        paths << full_text_path_for(document)
        paths << thumbnail_path_for(document)
        paths << thumbnail_path_for(document, 'small')
        paths.each {|path| FileUtils.rm(path) if File.exists?(path) }
      end
      
      # Delete the assets store entirely.
      def delete_database!
        FileUtils.rm_r(local_storage_path) if File.exists?(local_storage_path)
      end
      
      
      private 
      
      def local_storage_path
        "#{RAILS_ROOT}/tmp/asset_store"
      end
      
      def save_pdf(document)
        doc_path, real_path = document.pdf, pdf_path_for(document)
        return if !doc_path || doc_path == real_path
        FileUtils.cp(doc_path, real_path)
        document.pdf = real_path
      end
      
      def save_thumbnail(document, extension=nil)
        thumb_path = extension == 'small' ? document.small_thumbnail : document.thumbnail
        real_path = thumbnail_path_for(document, extension)
        return if !thumb_path || thumb_path == real_path
        FileUtils.cp(thumb_path, real_path)
        extension == 'small' ? document.small_thumbnail = real_path : document.thumbnail = real_path
      end
      
      def save_images(document)
        save_thumbnail(document)
        save_thumbnail(document, 'small')
      end
      
      def save_full_text(document)
        path = full_text_path_for(document)
        File.open(path, 'w+') {|f| f.write(document.full_text) }
      end
      
      def full_text_path_for(document)
        "#{local_storage_path}/#{document.id}.txt"
      end
      
      def pdf_path_for(document)
        "#{local_storage_path}/#{document.id}.pdf"
      end
      
      def thumbnail_path_for(document, extension=nil)
        ext = extension ? "_#{extension}" : ''
        "#{local_storage_path}/#{document.id}#{ext}.jpg"
      end
      
    end
    
  end
end