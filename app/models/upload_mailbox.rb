class UploadMailbox < ActiveRecord::Base
  
  EMAIL_DOMAIN = "upload.documentcloud.org"
  
  belongs_to :membership

  before_validation :ensure_recipient

  # TODO: Add email format validation here
  validates :sender, :recipient, presence: true

  def recipient_address
    "#{self.recipient}@#{EMAIL_DOMAIN}"
  end
  
  def ensure_recipient
    self.recipient ||= "#{membership.organization.slug}-#{SecureRandom.hex(4)}"
  end
end
