class Collaboration < ActiveRecord::Base

  belongs_to :project
  belongs_to :account
  belongs_to :membership

  belongs_to :creator, :class_name => "Account"

  scope :owned_by, lambda { |account|
    where( :account_id => account.id ) if account
  }

  scope :not_owned_by, lambda {|account|
    where( ["account_id != ?", account.id] ) if account
  }

  validates :project_id, :uniqueness=>{ :scope => :account_id }

  has_many :project_memberships, :through => :project

  # def self.invite_collaborator(creator_id, invitee_id, project_id)
  #   project = Project.find(project_id)
  #   creator = Account.find(creator_id)
  #   invitee = Account.find(invitee_id)

  #   self.create!(project: project, creator: creator, account: invitee)
  # end

  def accept_collaboration(membership_id)
    membership = self.account.memberships.find(membership_id)
    if membership
      self.update(membership: membership)
    else
      false
    end
  end
end
