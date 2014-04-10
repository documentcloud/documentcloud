require_relative 'aws_s3_store'
require_relative 'file_system_store'
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }

module DC
  module Store

    # The AssetStore is responsible for storing search-opaque document assets,
    # either on S3 (or in development on the local filesystem in a tmp dir).
    class AssetStore
      if Rails.env.development? || Rails.env.testing?
        include FileSystemStore
        extend FileSystemStore::ClassMethods
      else
        include AwsS3Store
        extend  AwsS3Store::ClassMethods
      end
    end

  end
end
