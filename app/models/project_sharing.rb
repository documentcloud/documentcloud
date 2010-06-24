class ProjectSharing < ActiveRecord::Base

  belongs_to :project
  belongs_to :account

  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  has_many :project_memberships, :through => :project

end