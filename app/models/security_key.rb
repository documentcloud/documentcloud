# A SecurityKey can be associated with any record, in order to hand out
# a secure URL to access it. At the moment, it's used when new accounts are
# created, for password creation and first log in.
class SecurityKey < ActiveRecord::Base

  HARDNESS = 10

  belongs_to  :securable, :polymorphic => true
  before_save :generate_key

  validates   :securable_type, :presence=>true
  validates   :securable_id,   :presence=>true, :uniqueness=>{ :scope => :securable_type }

  # To compare a SecurityKey with a potential match, check self.key.
  def ==(value)
    key == value
  end


  private

  def generate_key
    self.key ||= SecureRandom.hex(HARDNESS)
  end

end
