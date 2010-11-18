require 'set'

# A Project, (or Folder, Bucket, Tag, Collection, Notebook, etc.) is a
# name under which to group a set of related documents, purely for
# organizational purposes.
class Project < ActiveRecord::Base

  belongs_to :account
  has_many :project_memberships, :dependent => :destroy
  has_many :collaborations,      :dependent => :destroy
  has_many :documents,           :through => :project_memberships
  has_many :collaborators,       :through => :collaborations, :source => :account

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id

  after_create    :create_default_collaboration
  after_create    :reindex_documents
  before_destroy  :document_ids
  after_destroy   :reindex_documents

  named_scope :alphabetical, {:order => :title}

  named_scope :accessible, lambda {|account|
    {:conditions => ['account_id = ? or id in (select project_id from collaborations where account_id = ?)', account.id, account.id]}
  }

  delegate :full_name, :to => :account, :prefix => true

  attr_writer :annotation_count

  # Load all of the projects belonging to an account in one fell swoop.
  def self.load_for(account)
    self.accessible(account).all(:include => ['account', 'project_memberships', 'collaborations'])
  end

  def set_documents(new_ids)
    new_ids = new_ids.to_set
    old_ids = self.document_ids.to_set
    ProjectMembership.destroy_all(:project_id => id, :document_id => (old_ids - new_ids).to_a)
    (new_ids - old_ids).each {|doc_id| self.project_memberships.create(:document_id => doc_id) }
    reindex_documents new_ids ^ old_ids
    @document_ids = nil
  end

  def add_collaborator(account)
    self.collaborations.create(:account => account)
    @collaborator_ids = nil
  end

  def remove_collaborator(account)
    self.collaborations.owned_by(account).first.destroy
    @collaborator_ids = nil
  end

  def create_default_collaboration
    add_collaborator self.account
  end

  def other_collaborators(account)
    collaborations = self.collaborations.not_owned_by(account).all(:select => ['account_id'])
    Account.all(:conditions => {:id => collaborations.map {|c| c.account_id }})
  end

  def add_document(document)
    self.project_memberships.create(:document => document)
    @document_ids = nil
  end

  def document_ids
    @document_ids ||= project_memberships.map {|m| m.document_id }
  end

  def collaborator_ids
    @collaborator_ids ||= collaborations.not_owned_by(account).map {|m| m.account_id }
  end

  # How many annotations belong to documents belonging to this project?
  # How many of those annotations are accessible to a given account?
  def annotation_count(account=nil)
    account ||= self.account
    @annotation_count ||= Annotation.accessible(account).count(
      {:conditions => {:document_id => document_ids}}
    )
  end

  def canonical
    data = ActiveSupport::OrderedHash.new
    data['id']            = id
    data['title']         = title
    data['description']   = description
    data['document_ids']  = self.documents.all(:select => 'documents.id, slug').map {|doc| doc.canonical_id }
    data
  end

  def to_json(opts={})
    acc = opts[:account]
    attrs = attributes.merge(
      :account_full_name  => account_full_name,
      :annotation_count   => annotation_count(acc),
      :document_ids       => document_ids
    )
    if opts[:include_collaborators]
      attrs[:collaborators] = other_collaborators(acc).map {|c| c.canonical(:include_organization => true) }
    end
    attrs.to_json
  end


  private

  def reindex_documents(ids=nil)
    ids ||= self.document_ids
    return if ids.empty?
    Document.all(:conditions => ["id in (?)", ids]).each {|doc| doc.index }
  end

end