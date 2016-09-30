class UploadMailbox < ActiveRecord::Base
  
  EMAIL_DOMAIN = "upload.documentcloud.org"
  
  belongs_to :membership
  validates :sender, presence: true
  validates :recipient, presence: true
  
  before_validation :ensure_recipient
  
  def recipient_address
    "#{self.recipient}@#{EMAIL_DOMAIN}"
  end
  
  def ensure_recipient
    self.recipient ||= "#{membership.organization.slug}-#{SecureRandom.hex(4)}"
  end
end
