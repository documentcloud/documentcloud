class DocumentReviewer < ActiveRecord::Base

  belongs_to :document
  belongs_to :account

  validates_uniqueness_of :document_id, :scope => :account_id

end