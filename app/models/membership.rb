class Membership < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  validates_inclusion_of  :role, :in => ROLES

  belongs_to :organization
  belongs_to :account
end
