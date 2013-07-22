class Collaboration < ActiveRecord::Base

  belongs_to :project
  belongs_to :account
  belongs_to :creator, :class_name => "Account"

  scope :owned_by, lambda { |account|
    where( :account_id => account.id ) if account
  }

  scope :not_owned_by, lambda {|account|
    where( ["account_id != ?", account.id] ) if account
  }

  validates_uniqueness_of :project_id, :scope => :account_id

  has_many :project_memberships, :through => :project

end
