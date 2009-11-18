module DC
  module Store

    # An implementation of an AssetStore.
    module FileSystemStore

      module ClassMethods
        def asset_root
          "#{RAILS_ROOT}/public/asset_store"
        end
        def web_root
          File.join(DC_CONFIG['server_root'], 'asset_store')
        end
      end

      def initialize
        FileUtils.mkdir_p(AssetStore.asset_root) unless File.exists?(AssetStore.asset_root)
      end

      def save_files(document, assets)
        ensure_document_directory(document)
        FileUtils.cp(assets[:pdf], local(document.pdf_path))
        FileUtils.cp(assets[:thumbnail], local(document.thumbnail_path))
      end

      def save_full_text(document)
        ensure_document_directory(document)
        File.open(local(document.full_text_path), 'w+') {|f| f.write(document.text) }
      end

      def save_page(page, assets)
        FileUtils.mkdir_p(local(page.pages_path)) unless File.exists?(local(page.pages_path))
        FileUtils.cp(assets[:normal_image], local(page.image_path('normal')))
        FileUtils.cp(assets[:large_image], local(page.image_path('large')))
        File.open(local(page.text_path), 'w+') {|f| f.write(page.text) }
      end

      def read_pdf(document)
        File.read(local(document.pdf_path))
      end

      def destroy(document)
        doc_path = local(document.path)
        FileUtils.rm_r(doc_path) if File.exists?(doc_path)
      end

      # Delete the assets store entirely.
      def delete_database!
        FileUtils.rm_r(AssetStore.asset_root) if File.exists?(AssetStore.asset_root)
      end


      protected

      def ensure_document_directory(document)
        FileUtils.mkdir_p(local(document.path)) unless File.exists?(local(document.path))
      end

      def local(path)
        File.join(AssetStore.asset_root, path)
      end

    end

  end
end