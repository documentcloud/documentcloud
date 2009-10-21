class Label < ActiveRecord::Base
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  default_scope :order => 'title'
  
  def documents
    document_ids.split(',').map {|doc_id| Document.new(doc_id) }
  end
  
  def as_json(opts={})
    attributes
  end
  
end