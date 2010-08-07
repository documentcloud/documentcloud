class ProjectMembership < ActiveRecord::Base

  belongs_to :project
  belongs_to :document

  has_many :collaborations, :through => :project

  after_create  :reindex_document
  after_destroy :reindex_document

  def reindex_document
    self.document.index if self.document
  end

end