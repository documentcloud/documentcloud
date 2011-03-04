# An Account on DocumentCloud can be used to access the workspace and upload
# documents. Accounts have full priviledges for the entire organization, at the
# moment.
class Account < ActiveRecord::Base
  include DC::Access

  ADMINISTRATOR = 1
  CONTRIBUTOR   = 2
  REVIEWER      = 3

  ROLES = [ADMINISTRATOR, CONTRIBUTOR, REVIEWER]

  # Associations:
  belongs_to  :organization
  has_many    :projects,             :dependent => :destroy
  has_many    :annotations
  has_many    :collaborations,       :dependent => :destroy
  has_many    :processing_jobs,      :dependent => :destroy
  has_one     :security_key,         :dependent => :destroy, :as => :securable
  has_many    :shared_projects,      :through => :collaborations, :source => :project
  has_many    :document_reviewers,   :dependent => :destroy
  has_many    :reviewable_documents, :through => :document_reviewers, :source => :document

  # Validations:
  validates_presence_of   :first_name, :last_name, :email
  validates_format_of     :email, :with => DC::Validators::EMAIL
  validates_uniqueness_of :email, :case_sensitive => false
  validates_inclusion_of  :role, :in => ROLES

  # Sanitizations:
  text_attr :first_name, :last_name, :email

  # Delegations:
  delegate :name, :to => :organization, :prefix => true, :allow_nil => true

  # Scopes:
  named_scope :admin, {:conditions => {:role => ADMINISTRATOR}}
  named_scope :contributors, {:conditions => ["role IN (?)", [ADMINISTRATOR, CONTRIBUTOR]]}

  # Attempt to log in with an email address and password.
  def self.log_in(email, password, session=nil, cookies=nil)
    account = Account.lookup(email)
    return false unless account && account.password == password
    account.authenticate(session, cookies) if session && cookies
    account
  end

  def self.login_reviewer(key, session=nil, cookies=nil)
    security_key = SecurityKey.find_by_key(key)
    return nil unless security_key
    account = security_key.securable
    account.authenticate(session, cookies) if session && cookies
    account
  end

  # Retrieve the names of the contributors for the result set of documents.
  def self.names_for_documents(docs)
    ids = docs.map {|doc| doc.account_id }.uniq
    self.all(:conditions => {:id => ids}, :select => 'id, first_name, last_name').inject({}) do |hash, acc|
      hash[acc.id] = acc.full_name; hash
    end
  end

  def self.lookup(email)
    Account.first(:conditions => ['lower(email) = ?', email.downcase])
  end

  # Save this account as the current account in the session. Logs a visitor in.
  def authenticate(session, cookies)
    session['account_id']      = id
    session['organization_id'] = organization_id
    refresh_credentials(cookies)
    self
  end

  # Reset the logged-in cookie.
  def refresh_credentials(cookies)
    cookies['dc_logged_in'] = {:value => 'true', :expires => 1.month.from_now, :httponly => true}
  end

  def slug
    first = first_name && first_name.downcase.gsub(/\W/, '')
    last  = last_name && last_name.downcase.gsub(/\W/, '')
    @slug ||= "#{id}-#{first}-#{last}"
  end

  # Is this account an administrator?
  def admin?
    role == ADMINISTRATOR
  end

  # Is this account a contributor?
  def contributor?
    role == CONTRIBUTOR
  end

  # An account owns a resource if it's tagged with the account_id.
  def owns?(resource)
    resource.account_id == id
  end

  def collaborates?(resource)
    (admin? || contributor?) &&
      resource.organization_id == organization_id &&
      [ORGANIZATION, EXCLUSIVE, PUBLIC, PENDING, ERROR].include?(resource.access)
  end

  # Heavy-duty SQL.
  # A document is shared with you if it's in any project of yours, and that
  # project is in collaboration with an owner or and administrator of the document.
  def shared?(resource)
    collaborators = Account.find_by_sql(<<-EOS
      select distinct on (a.id)
      a.id as id, a.organization_id as organization_id, a.role as role
      from accounts as a
      inner join collaborations as c1
        on c1.account_id = a.id
      inner join collaborations as c2
        on c2.account_id = #{id} and c2.project_id = c1.project_id
      inner join projects as p
        on p.id = c1.project_id and p.hidden = false
      inner join project_memberships as pm
        on pm.project_id = c1.project_id and pm.document_id = #{resource.document_id}
      where a.id != #{id}
    EOS
    )
    collaborators.any? {|account| account.owns_or_collaborates?(resource) }
  end

  def owns_or_collaborates?(resource)
    owns?(resource) || collaborates?(resource)
  end

  def reviewer?
    !hashed_password && (role == REVIEWER)
  end

  def reviews?(resource)
    project = resource.projects.hidden.first
    project && project.reviewers.exists?(id)
  end

  def allowed_to_edit?(resource)
    owns_or_collaborates?(resource) || shared?(resource)
  end

  def accessible_document_ids
    return @accessible_document_ids unless @accessible_document_ids.nil?
    @accessible_document_ids = []

    if not accessible_project_ids.empty?
      @accessible_document_ids = ProjectMembership.connection.select_values(
        "select distinct document_id from project_memberships where project_id in (#{accessible_project_ids.join(',')})"
      ).map {|id| id.to_i }
    end

    @accessible_document_ids.flatten!
  end

  # The list of all of the projects that have been shared with this account
  # through collaboration.
  def accessible_project_ids
    @accessible_project_ids ||=
      Collaboration.owned_by(self).all(:select => [:project_id]).map {|c| c.project_id }
  end

  # When an account is created by a third party, send an email with a secure
  # key to set the password.
  def send_login_instructions(admin=nil)
    create_security_key if security_key.nil?
    LifecycleMailer.deliver_login_instructions(self, admin)
  end

  def send_reviewer_instructions(documents, inviter_account, message=nil)
    key = nil
    if self.role == Account::REVIEWER
      create_security_key if self.security_key.nil?
      key = '?key=' + self.security_key.key
    end
    LifecycleMailer.deliver_reviewer_instructions(documents, inviter_account, self, message, key)
  end

  # Upgrading a reviewer account to a newsroom account also moves their
  # notes over to the (potentially different) organization.
  def upgrade_reviewer_to_real(organization, role)
    update_attributes :organization => organization, :role => role
    Annotation.update_all("organization_id = #{organization.id}", "account_id = #{account.id}")
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
    !hashed_password && role != REVIEWER
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

  def canonical(options={})
    attrs = {
      'id'                => id,
      'slug'              => slug,
      'email'             => email,
      'first_name'        => first_name,
      'last_name'         => last_name,
      'organization_id'   => organization_id,
      'role'              => role,
      'hashed_email'      => hashed_email,
      'pending'           => pending?
    }
    attrs['organization_name'] = organization_name if options[:include_organization]
    if options[:include_document_counts]
      attrs['public_documents'] = Document.unrestricted.count(:conditions => {:account_id => id})
      attrs['private_documents'] = Document.restricted.count(:conditions => {:account_id => id})
    end
    attrs
  end

  # The JSON representation of an account avoids sending down the password,
  # among other things, and includes extra attributes.
  def to_json(options={})
    canonical(options).to_json
  end

end
