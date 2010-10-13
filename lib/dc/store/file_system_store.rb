module DC
  module Store

    # An implementation of an AssetStore.
    module FileSystemStore

      module ClassMethods
        def asset_root
          "#{Rails.root}/public/asset_store"
        end
        def web_root
          File.join(DC.server_root, 'asset_store')
        end
      end

      def initialize
        FileUtils.mkdir_p(AssetStore.asset_root) unless File.exists?(AssetStore.asset_root)
      end

      def read(path)
        File.read(local(path))
      end

      def authorized_url(path)
        File.join(self.class.web_root, path)
      end

      def list(path)
        Dir[local("#{path}/**/*")].map {|f| f.sub(AssetStore.asset_root + '/', '') }
      end

      def save_pdf(document, pdf_path, access=nil)
        ensure_directory(document.path)
        FileUtils.cp(pdf_path, local(document.pdf_path))
      end

      def save_insert_pdf(document, pdf_path, access=nil)
        path = File.join(document.path, 'inserts')
        ensure_directory(path)
        FileUtils.cp(pdf_path, local(path))
      end
      
      def delete_insert_pdfs(document)
        path = local(File.join(document.path, 'inserts'))
        FileUtils.rm_r(path) if File.exists?(path)
      end

      def save_full_text(document, access=nil)
        ensure_directory(document.path)
        File.open(local(document.full_text_path), 'w+') {|f| f.write(document.text) }
      end

      def save_rdf(document, rdf, access=nil)
        ensure_directory(document.path)
        File.open(local(document.rdf_path), 'w+') {|f| f.write(rdf) }
      end

      def save_page_images(document, page_number, images, access=nil)
        ensure_directory(document.pages_path)
        Page::IMAGE_SIZES.keys.each do |size|
          if images[size]
            FileUtils.cp(images[size], local(document.page_image_path(page_number, size)))
          end
        end
      end

      def save_page_text(document, page_number, text, access=nil)
        ensure_directory(document.pages_path)
        File.open(local(document.page_text_path(page_number)), 'w+') {|f| f.write(text) }
      end

      def save_database_backup(name, path)
        ensure_directory("backups/#{name}")
        FileUtils.cp(path, local("backups/#{name}/#{Date.today}.dump"))
      end

      def set_access(document, access)
        # No-op for the FileSystemStore.
      end

      def read_pdf(document)
        read document.pdf_path
      end

      def destroy(document)
        delete document.path
      end


      protected

      def ensure_directory(path)
        FileUtils.mkdir_p(local(path)) unless File.exists?(local(path))
      end

      def local(path)
        File.join(AssetStore.asset_root, path)
      end

      def save_file(file, path, access=nil)
        FileUtils.cp(path, local(file))
      end

    end

  end
end