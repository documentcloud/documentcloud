class ProjectMembership < ActiveRecord::Base

  belongs_to :project
  belongs_to :document

  has_many :collaborations, :through => :project

  validates_uniqueness_of :document_id, :scope => :project_id

end