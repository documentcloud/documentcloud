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

  validates :requester_email,
    presence: true,
    format: { :with => DC::Validators::EMAIL }

  validates :requester_first_name, :requester_last_name, :organization_name, :agreed_to_terms,
    presence: true

  validates :requester_position, presence: true, if: :requester_is_approver?

  with_options if: :in_market? do |target|
    target.validates :approver_first_name, :approver_last_name, :reference_links,
      presence: true
    target.validates :approver_email,
      presence: true,
      format: { :with => DC::Validators::EMAIL }
  end

  with_options unless: :in_market? do |non_target|
    non_target.validates :industry, :use_case,
      presence: true
  end

  def requester_full_name
    "#{requester_first_name} #{requester_last_name}"
  end

  def approver_full_name
    "#{approver_first_name} #{approver_last_name}"
  end

  def requester_is_approver?
    requester_full_name == approver_full_name && requester_email == approver_email
  end

end
