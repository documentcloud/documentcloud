class Label < ActiveRecord::Base
  
  belongs_to :account
  
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id
  
  before_validation :set_document_ids
  
  default_scope :order => 'title'
  
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