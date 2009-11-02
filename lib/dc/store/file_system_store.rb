module DC
  module Store
    
    # An implementation of an AssetStore.
    module FileSystemStore
      
      module ClassMethods
        def asset_root
          "#{RAILS_ROOT}/public/asset_store"
        end
      end
      
      def initialize
        FileUtils.mkdir_p(AssetStore.asset_root) unless File.exists?(AssetStore.asset_root)
      end
      
      def save(document, assets)
        FileUtils.mkdir_p(local(document.path)) unless File.exists?(local(document.path))
        FileUtils.cp(assets[:pdf], local(document.pdf_path))
        FileUtils.cp(assets[:thumbnail], local(document.thumbnail_path))
        File.open(local(document.full_text_path), 'w+') {|f| f.write(document.text) }
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
      
      def local(path)
        File.join(AssetStore.asset_root, path)
      end
      
    end
    
  end
end