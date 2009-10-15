module DC
  module Store
    
    # The AssetStore is responsible for storing search-opaque document assets, 
    # either on S3 (or in development on the local filesystem in a tmp dir).
    class AssetStore
      include RAILS_ENV == 'development' ? 
              DC::Store::FileSystemStore : 
              DC::Store::S3Store
    end
    
  end
end