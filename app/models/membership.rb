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

  def canonical( options={} )
    attrs = self.as_json
    if options[:include_account]
      attrs[:account] = account.canonical( options[:include_account] )
    end
    attrs
  end

end
