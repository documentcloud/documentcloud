
namespace :documents do

  desc "Set the file_hash attribute for older documents that did not have it set when they were created"
  task :set_hash => :environment do
    conditions = { :conditions => {:file_hash=>nil} }
    asset_store = DC::Store::AssetStore.new
    count = 0
    total = Document.where( conditions ).count
    Document.where( conditions ).find_each do | document |
      document.update_attributes! :file_hash => Digest::SHA1.hexdigest( asset_store.read_original(document) )
      Rails.logger.info "%08i/%i - Document %i => %s" % [ count+=1, total, document.id,  document.file_hash ] if 0 == count % 100
    end
  end

end
