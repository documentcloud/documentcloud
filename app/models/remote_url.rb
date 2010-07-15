class RemoteUrl < ActiveRecord::Base

  self.establish_connection(ANALYTICS_DB)
  
  def self.record_hits(doc_id, url, hits)
    row = self.find_or_create_by_document_id_and_url_and_date_recorded(doc_id, url, Time.now.utc.to_date)
    row.update_attributes :hits => row.hits + hits
  end

  # Return the top documents (with a :limit option) with the most hits.
  def self.top_documents_all_time(options={})
    self.all(options.merge({:group => 'document_id', :order => 'hits desc'})).map do |remote|
      doc            = remote.document
      doc.remote_url = remote.url
      doc.hits       = remote.hits
      doc
    end
  end
  
  def self.top_documents(days=7, options={})
    self.all({:select => 'sum(hits) AS hits, document_id, url', 
              :conditions => ['date_recorded > ?', days.days.ago], 
              :group => 'document_id, url', 
              :order => 'hits desc'}.merge(options))
  end

end