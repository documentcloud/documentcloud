class Membership < ActiveRecord::Base
  include DC::Access
  include DC::Roles

  validates_inclusion_of  :role, :in => ROLES
  validates_uniqueness_of :account_id, :scope => :organization_id

  belongs_to :organization
  belongs_to :account

  # don't need/want to filter any attributues, method
  # is provided only as a convenience in order to match other models
  def canonical
    self.as_json
  end

end
