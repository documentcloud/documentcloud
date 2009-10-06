class Account < ActiveRecord::Base
  
  belongs_to :organization
  
  validates_presence_of   :first_name, :last_name, :email, :hashed_password
  validates_format_of     :email, :with => DC::Validators::EMAIL
  validates_uniqueness_of :email
  
  def self.log_in(login, password)
  end
  
  # It's slo-o-o-w to compare passwords. Which is a mixed bag, but mostly good.
  def password
    @password ||= BCrypt::Password.new(hashed_password)
  end
  
  # BCrypt'd passwords helpfuly have the salt built-in.
  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.hashed_password = @password
  end
  
end