class Membership < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  validates_inclusion_of  :role, :in => ROLES
  validates_uniqueness_of :account_id, :scope => :organization_id

  belongs_to :organization
  belongs_to :account

  named_scope :real,      { :conditions => ["memberships.role in (?)", REAL_ROLES] }

  def real?
    REAL_ROLES.include?(role)
  end

  def canonical( options = {} )
    attrs = self.as_json
    attrs['account']           = account.canonical(options)      if options[:include_account]
    attrs['organization']      = organization.canonical(options) if options[:include_organization]
    attrs['organization_name'] = organization.name               if options[:include_organization_name]
    attrs
  end
  
  def to_json(options={})
    canonical(options).to_json
  end
end
