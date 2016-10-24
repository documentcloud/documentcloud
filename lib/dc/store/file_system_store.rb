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

      def read_size(path)
        File.size?(local(path))
      end

      def authorized_url(path, opts={})
        File.join(self.class.web_root, path)
      end

      def list(path)
        Dir[local("#{path}/**/*")].map {|f| f.sub(AssetStore.asset_root + '/', '') }
      end
      
      def save_original(document, file_path, access=nil)
        ensure_directory(document.path)
        FileUtils.cp(file_path, local(document.original_file_path))
      end
      
      def delete_original(document)
        ensure_directory(document.path)
        FileUtils.rm(local(document.original_file_path))
      end

      def save_pdf(document, pdf_path, access=nil)
        ensure_directory(document.path)
        FileUtils.cp(pdf_path, local(document.pdf_path))
      end

      def save_insert_pdf(document, pdf_path, pdf_name, access=nil)
        path = File.join(document.path, 'inserts')
        ensure_directory(path)
        FileUtils.cp(pdf_path, File.join(local(path), pdf_name))
      end

      def delete_insert_pdfs(document)
        delete File.join(document.path, 'inserts')
      end

      def save_full_text(document, access=nil)
        ensure_directory(document.path)
        File.open(local(document.full_text_path), 'w+') {|f| f.write(document.combined_page_text) }
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

      def delete_page_images(document, page_number)
        Page::IMAGE_SIZES.keys.each do |size|
          FileUtils.rm(local(document.page_image_path(page_number, size)))
        end
      end

      def save_page_text(document, page_number, text, access=nil)
        ensure_directory(document.pages_path)
        File.open(local(document.page_text_path(page_number)), 'w+') {|f| f.write(text) }
      end

      def delete_page_text(document, page_number)
        FileUtils.rm(local(document.page_text_path(page_number)))
      end
      
      def save_tabula_page(document, page_number, data, access=nil)
        tabula_page_path = document.page_text_path(page_number).sub(/txt$/, 'csv')
        ensure_directory(File.dirname(tabula_page_path))
        File.open(local(tabula_page_path), 'w+') {|f| f.write(data) }
      end
      
      def delete_tabula_page(document, page_number)
        FileUtils.rm(local(document.page_text_path(page_number).sub(/txt$/, 'csv')))
      end

      def save_backup(src, dest)
        ensure_directory("backups/#{File.dirname(dest)}")
        FileUtils.cp(src, local("backups/#{dest}"))
      end

      def set_access(document, access)
        # No-op for the FileSystemStore.
      end
      
      def read_original(document)
        read document.original_file_path
      end

      def read_pdf(document)
        read document.pdf_path
      end

      def destroy(document)
        delete document.path
      end

      def delete(path)
        doc_path = local(path)
        FileUtils.rm_r(doc_path) if File.exists?(doc_path)
      end
      
      # Duplicate all of the assets from one document over to another.
      def copy_assets(source, destination, access)
        [:copy_pdf, :copy_images, :copy_text].each do |task|
          send(task, source, destination, access)
        end
        true
      end
      
      def copy_text(source, destination, access)
        ensure_directory(destination.path)
        ensure_directory(destination.pages_path)
        FileUtils.cp local(source.full_text_path), local(destination.full_text_path)
        source.pages.each do |page|
          num = page.page_number
          FileUtils.cp local(source.page_text_path(num)), local(destination.page_text_path(num))
        end
        true
      end
      
      def copy_images(source, destination, access)
        ensure_directory(destination.path)
        ensure_directory(destination.pages_path)
        source.pages.each do |page|
          num = page.page_number
          Page::IMAGE_SIZES.keys.each do |size|
            FileUtils.cp local(source.page_image_path(num, size)), local(destination.page_image_path(num, size))
          end
        end
        true
      end
      
      def copy_rdf(source, destination, access)
        ensure_directory(destination.path)
        FileUtils.cp local(source.rdf_path), local(destination.rdf_path) if File.exists?(source.rdf_path)
        true
      end
      
      def copy_pdf(source, destination, access)
        ensure_directory(destination.path)
        FileUtils.cp local(source.pdf_path), local(destination.pdf_path)
        true
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
