# An Account on DocumentCloud can be used to access the workspace and upload
# documents. Accounts have full priviledges for the entire organization, at the
# moment.

class Account < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  # Associations:
  has_many :memberships
  has_many :organizations,   :through => :memberships
  has_many :projects,        :dependent => :destroy
  has_many :annotations
  has_many :collaborations,  :dependent => :destroy
  has_many :processing_jobs, :dependent => :destroy
  has_one  :security_key,    :dependent => :destroy, :as => :securable
  has_many :shared_projects, :through => :collaborations, :source => :project


  # Validations:
  validates_presence_of   :first_name, :last_name# => :has_memberships?
  validates_presence_of   :email, :if => :has_memberships?
  validates_format_of     :email, :with => DC::Validators::EMAIL, :if => :has_memberships?
  validates_uniqueness_of :email, :case_sensitive => false, :if => :has_memberships?
  validate :validate_identity_is_unique

  # Sanitizations:
  text_attr :first_name, :last_name, :email

  # Delegations:
  delegate :name, :to => :organization, :prefix => true, :allow_nil => true

  # Scopes
  scope :with_memberships, -> { references(:memberships).includes(:memberships) }
  scope :admin,   -> { with_memberships.where( ["memberships.role = ?",  ADMINISTRATOR] )  }
  scope :active,  -> { with_memberships.where( ["memberships.role is NULL or memberships.role != ?", DISABLED] ) }
  scope :real,    -> { with_memberships.where( ["memberships.role in (?)", REAL_ROLES] ) }
  scope :reviewer,-> { with_memberships.where( ["memberships.role = ?",    REVIEWER] ) }
  scope :with_identity, lambda { | provider, id |
     where("identities @> hstore(:provider, :id)", :provider=>provider.to_s,:id=>id.to_s )
  }

  # Populates the organization#members accessor with all the organizaton's accounts
  def organizations_with_accounts
    Organization.populate_members_info( self.organizations, self )
  end

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
    Account.where(['lower(email) = ?', email.downcase]).first
  end

  # 
  def self.from_identity( identity )
    account = Account.with_identity( identity['provider'],  identity['uid'] ).first || Account.new()
    account.record_identity_attributes( identity )
    account.save if account.changed?
    account
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

  def self.make_slug(account)
    first = account['first_name'] && account['first_name'].downcase.gsub(/\W/, '')
    last  = account['last_name'] && account['last_name'].downcase.gsub(/\W/, '')
    "#{account['id']}-#{first}-#{last}"
  end

  def slug
    @slug ||= Account.make_slug(self)
  end

  # Shims to preserve API backwards compatability.
  def organization
    @organization ||= Organization.default_for(self)
  end

  def organization_id
    return nil unless self.organization
    self.organization.id
  end
  
  def role
    default = memberships.where({:default=>true}).first
    default.nil? ? nil : default.role 
  end
  
  def member_of?(org)
    self.memberships.exists?(:organization_id => org.id)
  end
  
  def has_memberships? # should be reworked as Account#real?
    self.memberships.exists?
  end

  def has_role?(role, org=nil)
    if org.nil?
      self.memberships.exists?(:role => role)
    else
      self.memberships.exists?(:role => role, :organization_id => org.id)
    end
  end
  
  def admin?(org=self.organization)
    has_role?(ADMINISTRATOR, org)
  end
  
  def contributor?(org=self.organization)
    has_role?(CONTRIBUTOR, org)
  end

  def reviewer?(org=self.organization)
    has_role?(REVIEWER, org)
  end

  def freelancer?(org=self.organization)
    has_role?(FREELANCER, org)
  end

  def real?(org=self.organization)
    admin?(org) || contributor?(org) || freelancer?(org)
  end

  def disabled?(org=self.organization)
    self.memberships.exists?({ :role=>DISABLED, :organization_id => org })
  end

  def active?(org=self.organization)
    membership = self.memberships.first(:conditions=>{:organization_id => org})
    membership && membership.role != DISABLED
  end

  # An account owns a resource if it's tagged with the account_id.
  def owns?(resource)
    resource.account_id == id
  end

  def collaborates?(resource) # Flagged to rewrite
    (admin? || contributor?) &&
      resource.organization_id == organization_id &&
      SHARED_ACCESS.include?(resource.access)
  end

  # Heavy-duty SQL.
  # A document is shared with you if it's in any project of yours, and that
  # project is in collaboration with an owner or and administrator of the document.
  # Note that shared? is not the same as reviews?, as it ignores hidden projects.
  def shared?(resource)
    # organization_id will no long be returned on account queries
    collaborators = Account.find_by_sql(<<-EOS
      select distinct on (a.id)
      a.id as id, m.organization_id as organization_id, m.role as role
      from accounts as a
      inner join collaborations as c1
        on c1.account_id = a.id
      inner join collaborations as c2
        on c2.account_id = #{id} and c2.project_id = c1.project_id
      inner join projects as p
        on p.id = c1.project_id and p.hidden = false
      inner join project_memberships as pm
        on pm.project_id = c1.project_id and pm.document_id = #{resource.document_id}
      left outer join memberships as m on m.account_id = #{id}
      where a.id != #{id}
    EOS
    )
    # check for knockon effects in identifying whether an account owns/collabs on a resource.
    collaborators.any? {|account| account.owns_or_collaborates?(resource) }
  end

  def allowed_to_comment?( resource )
    [PREMODERATED,POSTMODERATED].include?( resource.access ) or allowed_to_edit?(resource) or reviews?(resource)
  end

  def owns_or_collaborates?(resource)
    owns?(resource) || collaborates?(resource)
  end

  # Effectively the same as Account#shares?, but for hidden projects used for reviewers.
  def reviews?(resource)
    project = resource.projects.hidden.first
    project && project.collaborators.exists?(id)
  end

  def allowed_to_edit?(resource)
    owns_or_collaborates?(resource) || shared?(resource)
  end

  def allowed_to_edit_account?(account, org=self.organization)
    (self.id == account.id) ||
    ((self.admin?(org) && account.member_of?(org)) || (self.member_of?(org) && account.reviewer?(org)))
  end

  def shared_document_ids
    return @shared_document_ids if @shared_document_ids
    @shared_document_ids ||= accessible_project_ids.empty? ? [] :
      ProjectMembership.connection.select_values(
        "select distinct document_id from project_memberships where project_id in (#{accessible_project_ids.join(',')})"
      ).map {|id| id.to_i }
  end

  # The list of all of the projects that have been shared with this account
  # through collaboration.
  def accessible_project_ids
    @accessible_project_ids ||=
      Collaboration.owned_by(self).all(:select => [:project_id]).map {|c| c.project_id }
  end
  
  # is the account considered an DocumentCloud Administrator?
  def dcloud_admin?
    organization.id == 1 && ! reviewer?    
  end

  # When an account is created by a third party, send an email with a secure
  # key to set the password.
  def send_login_instructions(admin=nil)
    create_security_key if security_key.nil?
    LifecycleMailer.login_instructions(self, admin).deliver
  end

  def send_reviewer_instructions(documents, inviter_account, message=nil)
    key = nil
    if self.has_role?( Account::REVIEWER )
      create_security_key if self.security_key.nil?
      key = '?key=' + self.security_key.key
    end
    LifecycleMailer.reviewer_instructions(documents, inviter_account, self, message, key).deliver
  end

  # Upgrading a reviewer account to a newsroom account also moves their                 # 
  # notes over to the (potentially different) organization.                             # Move to Organization
  def upgrade_reviewer_to_real(organization, role)                                      # 
    update_attributes :organization => organization, :role => role                      # 
    Annotation.update_all("organization_id = #{organization.id}", "account_id = #{id}") # 
  end                                                                                   # 

  # When a password reset request is made, send an email with a secure key to
  # reset the password.
  def send_reset_request
    create_security_key if security_key.nil?
    LifecycleMailer.reset_request(self).deliver
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
    @hashed_email ||= Digest::MD5.hexdigest(email.downcase.gsub(/\s/, '')) if email
  end

  # Has this account been assigned, but never logged into, with no password set?
  def pending?
    !hashed_password && !reviewer? && identities.empty?
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

  def validate_identity_is_unique
    return if self.identities.empty?
    condition = self.identities.map{ | provider, id | "identities @> hstore(?,?)" }.join(' or ')
    condition << " and id<>#{self.id}" unless new_record?
    values = self.identities.map{|k,v| [k.to_s,v.to_s] }.flatten
    if account = Account.where( [ condition, *values ] ).first
      duplicated = account.identities.to_set.intersection( self.identities ).map{|k,v| k}.join(',')
      errors.add(:identities, "An account exists with the same id for #{account.id} #{account.identities.to_json} #{duplicated}")
    end
  end

  def record_identity_attributes( identity )
    current_identities = self.identities
    current_identities[ identity['provider'] ] = identity['uid']
    write_attribute( :identities, DC::Hstore.to_sql(  current_identities ) )

    info = identity['info']

    # only overwrite account's email if it is blank no-one else is using it
    self.email = info['email'] if info['email'] && self.email.blank? && Account.lookup( info['email'] ).nil?

    %w{ first_name last_name }.each do | attr |
      write_attribute( attr, info[attr] ) if read_attribute(attr).blank? && info[attr]
    end
    if self.first_name.blank? && ! info['name'].blank?
      self.first_name = info['name'].split(' ').first
    end
    if self.last_name.blank? && ! info['name'].blank?
      self.last_name = info['name'].split(' ').last
    end

    self
  end


  # Create default organization to preserve backwards compatability.
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
    if options[:include_organization]
      attrs['organization_name'] = organization_name
      attrs['organizations']     = organizations.map(&:canonical)
    end
    if options[:include_document_counts]
      attrs['public_documents'] = Document.unrestricted.where(:account_id=>id).count
      attrs['private_documents'] = Document.restricted.where(:account_id => id).count
    end
    attrs
  end

  # The JSON representation of an account avoids sending down the password,
  # among other things, and includes extra attributes.
  def to_json(options={})
    canonical(options).to_json
  end

end
