class Label < ActiveRecord::Base
  
  validates_presence_of :title
  default_scope :order => 'name'
  
  def documents
    document_ids.split(',').map {|doc_id| Document.new(doc_id) }
  end
  
end