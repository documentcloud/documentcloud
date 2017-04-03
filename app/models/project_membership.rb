class ProjectMembership < ActiveRecord::Base

  belongs_to :project
  belongs_to :document
  # belongs_to :membership

  has_many :collaborations, :through => :project

  validates :document_id, :uniqueness=>{ :scope => :project_id }

end
