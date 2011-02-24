class DocumentReviewerInviter < ActiveRecord::Base

  belongs_to :document
    
  validates_uniqueness_of :reviewer_account_id, :scope => :document_id
  
end