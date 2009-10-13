class SecurityKey < ActiveRecord::Base
  
  HARDNESS = 10

  belongs_to  :securable, :polymorphic => true
  before_save :generate_key
  
  validates_presence_of   :securable_type, :securable_id
  validates_uniqueness_of :securable_id, :scope => :securable_type
  
  # To compare a SecurityKey with a potential match, check self.key.
  def ==(value)
    key == value
  end
  
  
  private
  
  def generate_key
    self.key ||= ActiveSupport::SecureRandom.hex(HARDNESS)
  end
  
end
