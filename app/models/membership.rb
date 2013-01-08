class Membership < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  validates_inclusion_of  :role, :in => ROLES

  belongs_to :organization
  belongs_to :account
  
  def admin?
    role == ADMINISTRATOR
  end

  def contributor?
    role == CONTRIBUTOR
  end

  def reviewer?
    role == REVIEWER
  end

  def freelancer?
    role == FREELANCER
  end

  def real?
    admin? || contributor?
  end

  def active?
    role != DISABLED
  end
end
