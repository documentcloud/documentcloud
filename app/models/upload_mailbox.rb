class UploadMailbox < ActiveRecord::Base
  
  before_validation :ensure_recipient
  
  def ensure_recipient
    self.recipient ||= "#{membership.organization.slug}-#{SecureRandom(4)}"
  end
end
