# A Project, (or Folder, Bucket, Tag, Collection, Notebook, etc.) is a
# name under which to group a set of related documents, purely for
# organizational purposes.
class Project < ActiveRecord::Base

  belongs_to :account
  has_many :project_memberships, :dependent => :destroy
  # has_many :documents,           :through => :project_memberships

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id

  before_validation :set_document_ids

  named_scope :alphabetical, {:order => :title}

  # Instead of having a join table, Projects serialize their comma-separated
  # document ids. Split them back apart.
  def split_document_ids
    document_ids.nil? ? [] : document_ids.split(',').map(&:to_i).uniq
  end

  # How many annotations belong to documents belonging to this project?
  def annotation_count
    Annotation.count({:conditions => {:account_id => account_id, :document_id => split_document_ids}})
  end

  def to_json(opts={})
    attributes.merge(:annotation_count => annotation_count).to_json
  end

  private

  # Before saving a project, we ensure that it doesn't reference any duplicates.
  def set_document_ids
    self.document_ids = split_document_ids.join(',')
  end

end