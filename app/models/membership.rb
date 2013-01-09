class Membership < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  validates_inclusion_of  :role, :in => ROLES
  validates_uniqueness_of :account_id, :scope => :organization_id

  belongs_to :organization
  belongs_to :account
end
