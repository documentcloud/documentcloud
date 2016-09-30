class UploadMailbox < ActiveRecord::Base
  
  belongs_to :membership
  validates :sender, presence: true
  validates :recipient, presence: true
  
  before_validation :ensure_recipient
  
  def ensure_recipient
    self.recipient ||= "#{membership.organization.slug}-#{SecureRandom.hex(4)}"
  end
end
