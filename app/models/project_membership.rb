class ProjectMembership < ActiveRecord::Base

  belongs_to :project
  belongs_to :document

  has_many :collaborations, :through => :project

  validates :document_id, :uniqueness=>{ :scope => :project_id }

end
