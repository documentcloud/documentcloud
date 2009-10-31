class Label < ActiveRecord::Base
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  before_validation :set_document_ids
  
  default_scope :order => 'title'
  
  # Scope to the labels owned by the current account.
  named_scope :owned, lambda {
    {:conditions => {:account_id => Account.current.id}}
  }
  
  def split_document_ids
    document_ids.nil? ? [] : document_ids.split(',').map(&:to_i).uniq
  end
  
  def to_json(opts={})
    attributes.to_json
  end
  
  
  private
  
  def set_document_ids
    self.document_ids = split_document_ids.join(',')
  end
  
end