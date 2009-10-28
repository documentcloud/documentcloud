class Label < ActiveRecord::Base
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  default_scope :order => 'title'
  
  # Scope to the labels owned by the current account.
  named_scope :owned, lambda {
    {:conditions => {:account_id => Account.current.id}}
  }
  
  def documents
    split_document_ids.map {|doc_id| Document.new(:id => doc_id) }
  end
  
  def split_document_ids
    document_ids.nil? ? [] : document_ids.split(',')
  end
  
  def loaded_documents
    DC::Store::EntryStore.new.find_all(document_ids.split(','))
  end
  
  def to_json(opts={})
    attributes.to_json
  end
  
end