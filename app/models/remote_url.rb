class RemoteUrl < ActiveRecord::Base

  belongs_to :document

  def self.record_hits(doc_id, url, hits)
    row = RemoteUrl.find_or_create_by_document_id_and_url(doc_id, url)
    row.update_attributes :hits => row.hits + hits
  end

end