class DocumentReviewer < ActiveRecord::Base

  belongs_to :document, :counter_cache => true
  belongs_to :account

  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }
  
  validates_uniqueness_of :document_id, :scope => :account_id

end