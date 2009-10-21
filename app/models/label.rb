class Label < ActiveRecord::Base
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  default_scope :order => 'title'
  
  def documents
    document_ids.split(',').map {|doc_id| Document.new(:id => doc_id) }
  end
  
  def loaded_documents
    DC::Store::EntryStore.new.find_all(document_ids.split(','))
  end
  
  def as_json(opts={})
    attributes
  end
  
end