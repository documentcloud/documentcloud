class ProjectMembership < ActiveRecord::Base

  belongs_to :project
  belongs_to :document

  has_many :project_sharings, :through => :project

end