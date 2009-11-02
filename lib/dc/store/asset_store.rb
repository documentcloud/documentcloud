module DC
  module Store
    
    # The AssetStore is responsible for storing search-opaque document assets, 
    # either on S3 (or in development on the local filesystem in a tmp dir).
    class AssetStore
      if RAILS_ENV == 'development'
        include FileSystemStore
        extend FileSystemStore::ClassMethods
      else
        include S3Store
        extend S3Store::ClassMethods
      end
    end
    
  end
end