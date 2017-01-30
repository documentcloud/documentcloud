class Membership < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  belongs_to :organization
  belongs_to :account

  validates :role,       inclusion:  { in: ROLES }
  validates :account_id, uniqueness: { scope: :organization_id }

  scope :real,    -> { where(["memberships.role in (?)", REAL_ROLES]) }
  scope :default, -> { where(default: true) }

  def real?
    REAL_ROLES.include?(role)
  end

  def role_name
    ROLE_NAMES[role].to_s
  end

  def canonical(options={})
    attrs = self.attributes
    attrs[:account]      = account.canonical(options)      if options[:include_account]
    # Singular and plural `organizations` for backwards-compatibility
    attrs[:organization] = organization.canonical(options) if (options[:include_organizations] || options[:include_organization])
    attrs
  end

  def as_json(options={})
    canonical(options)
  end

  def member?(account_id, organization_id)
    account = Account.find(account_id)
    organization = organization.find(organization_id)
    where(account: account, organization: organization).none? ? false : true
  end
end
