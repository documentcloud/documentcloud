class Collaboration < ActiveRecord::Base

  belongs_to :project
  belongs_to :account

  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  validates_uniqueness_of :project_id, :scope => :account_id

  has_many :project_memberships, :through => :project

end