class VerificationRequest < ActiveRecord::Base
  REJECTED = 0
  PENDING  = 1
  VERIFIED = 2
  SEE_NOTE = 3
  
  STATUS_MAP = {
    rejected: 0,
    pending:  1,
    verified: 2,
    see_note: 3
  }
  STATUS_NAMES = STATUS_MAP.invert
  
  belongs_to :account

  validates :requester_email, :approver_email,
    presence: true, 
    format: { :with => DC::Validators::EMAIL }
    
  validates :requester_first_name, :requester_last_name, :approver_first_name, :approver_last_name,
            :organization_name,
    presence: true
  
  validates :agreed_to_terms, :presence => { :message => 'must be checked' }
  
  validates :display_language, :inclusion => { :in => DC::Language::USER,
    :message => "must be one of: (#{DC::Language::USER.join(', ')})" }
  validates :document_language, :inclusion => { :in => DC::Language::SUPPORTED,
    :message => "must be one of: (#{DC::Language::SUPPORTED.join(', ')})" }

end
