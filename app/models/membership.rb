class Membership < ActiveRecord::Base
  include DC::Access
  
  DISABLED      = 0
  ADMINISTRATOR = 1
  CONTRIBUTOR   = 2
  REVIEWER      = 3
  FREELANCER    = 4

  ROLES = [ADMINISTRATOR, CONTRIBUTOR, REVIEWER, FREELANCER, DISABLED]

  validates_inclusion_of  :role, :in => ROLES

  belongs_to :organization
  belongs_to :account
  
end
