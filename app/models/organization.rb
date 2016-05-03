# A (News or Watchdog) organization with the power to create DocumentCloud
# accounts and upload documents.
class Organization < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include DC::Access
  include DC::Roles

  attr_accessor :document_count, :note_count, :members

  has_many :memberships, :dependent => :destroy
  has_many :accounts, :through => :memberships
  has_many :documents
  validates :name, :slug, :presence=>true
  validates :name, :slug, :uniqueness=>true
  validates :slug, :format => { :with => DC::Validators::SLUG_TEXT }

  validates :language, :inclusion=>{ :in => DC::Language::USER,
    :message => "must be one of: (#{DC::Language::USER.join(', ')})" }
  validates :document_language,  :inclusion=>{ :in => DC::Language::SUPPORTED,
    :message => "must be one of: (#{DC::Language::SUPPORTED.join(', ')})" }

  # Sanitizations:
  text_attr :name

  def self.default_for(account)
    self.includes(:memberships)
      .where(["memberships.account_id = ? and memberships.default is true", account.id] )
      .references(:memberships)
      .first
  end

  # Retrieve the names of the organizations for the result set of documents.
  def self.names_for_documents(docs)
    ids = docs.map(&:organization_id).uniq
    self.where( :id=>ids ).pluck(:id, :name).inject({}) do |hash, org|
      hash[org.first] = org.last; hash
    end
  end

  # Retrieve the list of organizations with public documents, including counts.
  def self.listed
    public_doc_counts   = Document.unrestricted.group(:organization_id).count
    public_note_counts  = Annotation.public_note_counts_by_organization
    orgs = self.where({:id => public_doc_counts.keys, :demo => false})
    orgs.each do |org|
      org.document_count = public_doc_counts[org.id]  || 0
      org.note_count     = public_note_counts[org.id] || 0
    end
    orgs
  end

  # Retrieve all Organizations, just returning the name and slug.
  def self.all_slugs
    self.pluck('name, slug').map{ |name,slug| { 'name'=>name,'slug'=>slug } }
  end

  # Populates the members accessor with all the organizaton's accounts
  def self.populate_members_info( organizations, except_account=nil)
    return [] if organizations.empty?
    sql = <<-EOS
    select
      memberships.organization_id, memberships.role,
      accounts.id,                 accounts.email,
      accounts.first_name,         accounts.last_name,
      accounts.hashed_password,    accounts.identities,
      accounts.language
    from memberships
      inner join accounts on accounts.id = memberships.account_id
    where
      memberships.role in (#{Membership::REAL_ROLES.join(',')})
      and memberships.organization_id in (#{organizations.map(&:id).join(',')})
    EOS
    if except_account
      sql << "and memberships.account_id not in (#{except_account.id})"
    end
    rows = self.connection.select_all( sql )
    hidden_fields=%w{ organization_id hashed_password identities }
    accounts_map = rows.group_by{|row| row['organization_id'].to_i }
    organizations.each do | organization |
      account_details = accounts_map[organization.id]
      if account_details # if except_account is set, this could be nil
        organization.members = account_details.map do |account|
          account['slug'] = Account.make_slug( account )
          account['pending'] = account['hashed_password'].blank? && # algorithm from Account#pending?
                               Membership::REVIEWER != account['role'].to_i &&
                               DC::Hstore.from_sql( account['identities'] ).empty?
          account['hashed_email']=Digest::MD5.hexdigest( account['email'].downcase.gsub(/\s/, '') ) if account['email']

          account.delete_if{|field,value| hidden_fields.include?(field) }
          account
        end
      end
    end
    return organizations
  end

  # How many documents have been uploaded across the whole organization?
  def document_count
    @document_count ||= self.documents.count
  end

  def role_of(account)
    self.memberships.where({:account_id=>account.id}).first
  end

  def add_member(account, role, concealed=false)
    options = {:account_id => account.id, :role => role, :concealed => concealed}
    options[:default] = true unless account.memberships.exists?(:default=>true) # TODO: transition account#real? for this verification
    self.memberships.create(options)
  end

  def remove_member(account)
    self.memberships.where({:account_id=>account.id}).destroy_all
  end

  # The list of all administrator emails in the organization.
  def admin_emails
    self.accounts.admin.pluck( :email )
  end

  def as_json(options = {})
    canonical(options)
  end

  def canonical( options = {} )
    attrs = {
      'name'              => name,
      'slug'              => slug,
      'language'          => language,
      'document_language' => document_language,
      'demo'              => demo,
      'id'                => id
    }
    if options[:include_document_count]
      attrs['document_count'] = document_count
    end
    if options[:include_note_count] and @note_count
      attrs['note_count'] = @note_count
    end
    if self.members
      attrs['members'] = self.members
    end
    attrs
  end


end
