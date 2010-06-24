# An Account on DocumentCloud can be used to access the workspace and upload
# documents. Accounts have full priviledges for the entire organization, at the
# moment.
class Account < ActiveRecord::Base
  include DC::Access

  ADMINISTRATOR = 1
  CONTRIBUTOR   = 2

  # Associations:
  belongs_to  :organization
  has_many    :projects,          :dependent => :destroy
  has_many    :project_sharings,  :dependent => :destroy
  has_many    :processing_jobs,   :dependent => :destroy
  has_one     :security_key,      :dependent => :destroy, :as => :securable
  has_many    :shared_projects,   :through => :project_sharings

  # Validations:
  validates_presence_of   :first_name, :last_name, :email
  validates_format_of     :email, :with => DC::Validators::EMAIL
  validates_uniqueness_of :email, :case_sensitive => false

  # Delegations:
  delegate :name, :to => :organization, :prefix => true

  # Scopes:
  named_scope :admin, {:conditions => {:role => ADMINISTRATOR}}

  # Attempt to log in with an email address and password.
  def self.log_in(email, password, session=nil)
    account = Account.find_by_case_insensitive_email(email)
    return false unless account && account.password == password
    account.authenticate(session) if session
    account
  end

  # Retrieve the names of the contributors for the result set of documents.
  def self.names_for_documents(docs)
    ids = docs.map {|doc| doc.account_id }.uniq
    self.all(:conditions => {:id => ids}, :select => 'id, first_name, last_name').inject({}) do |hash, acc|
      hash[acc.id] = acc.full_name; hash
    end
  end

  def self.find_by_case_insensitive_email(email)
    Account.first(:conditions => ['lower(email) = ?', email.downcase])
  end

  # Save this account as the current account in the session. Logs a visitor in.
  def authenticate(session)
    session['account_id'] = id
    session['organization_id'] = organization_id
    self
  end

  # Is this account an administrator?
  def admin?
    role == ADMINISTRATOR
  end

  # An account owns a resource if it's tagged with the account_id.
  def owns?(resource)
    resource.account_id == id
  end

  def administers?(resource)
    admin? &&
      resource.organization_id == organization_id &&
      [ORGANIZATION, EXCLUSIVE, PUBLIC].include?(resource.access)
  end

  def shared?(resource)
    shared_document_ids.include?(resource.document_id)
  end

  def allowed_to_edit?(resource)
    owns?(resource) || administers?(resource) || shared?(resource)
  end

  # The ids of all the documents that have been shared with this account through
  # shared projects.
  def shared_document_ids
    @shared_document_ids ||= ProjectMembership.connection.select_values(<<-EOS
      select document_id from project_memberships
      inner join project_sharings
        on (project_memberships.project_id = project_sharings.project_id)
      where account_id = #{id}
    EOS
    ).map {|doc_id| doc_id.to_i }
  end

  # When an account is created by a third party, send an email with a secure
  # key to set the password.
  def send_login_instructions
    create_security_key if security_key.nil?
    LifecycleMailer.deliver_login_instructions(self)
  end

  # When a password reset request is made, send an email with a secure key to
  # reset the password.
  def send_reset_request
    create_security_key if security_key.nil?
    LifecycleMailer.deliver_reset_request(self)
  end

  # No middle names, for now.
  def full_name
    "#{first_name} #{last_name}"
  end

  # The ISO 8601-formatted email address.
  def rfc_email
    "\"#{full_name}\" <#{email}>"
  end

  # MD5 hash of processed email address, for use in Gravatar URLs.
  def hashed_email
    @hashed_email ||= Digest::MD5.hexdigest(email.downcase.gsub(/\s/, ''))
  end

  # Has this account been assigned, but never logged into, with no password set?
  def pending?
    !hashed_password
  end

  # It's slo-o-o-w to compare passwords. Which is a mixed bag, but mostly good.
  def password
    return false if hashed_password.nil?
    @password ||= BCrypt::Password.new(hashed_password)
  end

  # BCrypt'd passwords helpfully have the salt built-in.
  def password=(new_password)
    @password = BCrypt::Password.create(new_password, :cost => 8)
    self.hashed_password = @password
  end

  # The JSON representation of an account avoids sending down the password,
  # among other things, and includes extra attributes.
  def to_json(options={})
    attrs = { 'id'              => id,
      'email'           => email,
      'first_name'      => first_name,
      'last_name'       => last_name,
      'organization_id' => organization_id,
      'role'            => role,
      'hashed_email'    => hashed_email,
      'pending'         => pending?
    }
    attrs['shared_document_ids'] = shared_document_ids if options[:include_shared]
    attrs.to_json
  end

end