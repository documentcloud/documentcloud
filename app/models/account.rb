class Account < ActiveRecord::Base
  
  belongs_to :organization
  
  validates_presence_of   :first_name, :last_name, :email, :hashed_password
  validates_format_of     :email, :with => DC::Validators::EMAIL
  validates_uniqueness_of :email
  
  # Attempt to log in with an email address and password.
  def self.log_in(email, password, session)
    account = Account.find_by_email(email)
    return false unless account && account.password == password
    session['account_id'] = account.id
    session['organization_id'] = account.organization_id
    account
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