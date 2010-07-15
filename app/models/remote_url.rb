class RemoteUrl < ActiveRecord::Base

  self.establish_connection(ANALYTICS_DB)

  def self.record_hits(doc_id, url, hits)
    row = self.find_or_create_by_document_id_and_url_and_date_recorded(doc_id, url, Time.now.utc.to_date)
    row.update_attributes :hits => row.hits + hits
  end

  def self.top_documents(days=7, options={})
    urls = self.all({
      :select => 'sum(hits) AS hits, document_id, url',
      :conditions => ['date_recorded > ?', days.days.ago],
      :group => 'document_id, url',
      :order => 'hits desc'
    }.merge(options))
    docs = Document.find_all_by_id(urls.map {|u| u.document_id }).inject({}) do |memo, doc|
      memo[doc.id] = doc
      memo
    end
    urls.map {|url| url.populate(docs[url.document_id]) }
  end

  # Populate the hits and remote_url of a document, from the current model.
  def populate(doc)
    doc.hits = self.hits
    doc.remote_url = self.url
    doc
  end

end