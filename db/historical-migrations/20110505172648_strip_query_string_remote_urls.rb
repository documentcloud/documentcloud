class StripQueryStringRemoteUrls < ActiveRecord::Migration
  
  def self.up
    doc_ids = []
    docs = RemoteUrl.all(:conditions => ['url LIKE ? AND document_id is not NULL', '%?%']).group_by {|u| u.document_id }
    docs.each do |id, doc_urls|
      docs[id] = doc_urls.group_by {|h| h.date_recorded }
    end
    docs.each_pair do |doc_id, days|
      puts doc_id
      doc_ids << doc_id
      days.each_pair do |hit_date, hits|
        new_url, query_string = *hits[0].url.split('?', 2)
        total = hits.inject(0) {|sum, hit| sum += hit.hits }
        hits.shift.update_attributes :hits => total, :url => new_url
        hits.each {|hit| hit.destroy }
      end
    end
    
    # puts "Detecting top URLs for documents... #{doc_ids.inspect}"
    # RemoteUrl.populate_detected_document_ids(doc_ids)
  end

  def self.down
  end
end
