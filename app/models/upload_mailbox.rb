class UploadMailbox < ActiveRecord::Base
  
  EMAIL_DOMAIN = "upload.documentcloud.org"
  
  belongs_to :membership

  before_validation :ensure_recipient
  validates :recipient, presence: true
  validates :sender, {
    presence: true, format: {with: DC::Validators::EMAIL}
  }

  def self.lookup(sender, key)
    (self.where(sender:sender, recipient: key) || []).first
  end
  
  def recipient_address
    "#{self.recipient}@#{EMAIL_DOMAIN}"
  end
  
  def ensure_recipient
    self.recipient ||= "#{membership.organization.slug}-#{SecureRandom.hex(4)}"
  end
end
