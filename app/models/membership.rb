class Membership < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  validates :role,       :inclusion=>{ :in => ROLES }
  validates :account_id, :uniqueness=> { :scope => :organization_id }

  belongs_to :organization
  belongs_to :account

  scope :real,    ->{ where( ["memberships.role in (?)", REAL_ROLES] ) }
  scope :default, ->{ where(:default=>true) }

  def real?
    REAL_ROLES.include?(role)
  end

  def canonical( options = {} )
    attrs = self.attributes
    attrs['account']           = account.canonical(options)      if options[:include_account]
    attrs['organization']      = organization.canonical(options) if options[:include_organization]
    attrs['organization_name'] = organization.name               if options[:include_organization_name]
    attrs
  end
  
  def as_json(options={})
    canonical(options)
  end
end
