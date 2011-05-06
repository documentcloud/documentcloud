class PopulateDetectedRemoteUrlsOnStrippedQueryStrings < ActiveRecord::Migration
  def self.up
    doc_ids = RemoteUrl.all(:select => 'document_id', 
                            :group => 'document_id', 
                            :having => 'document_id IS NOT NULL').map {|d| d.document_id }
    puts "Detecting top URLs for documents... #{doc_ids.inspect}"
    RemoteUrl.populate_detected_document_ids(doc_ids)
  end

  def self.down
  end
end
