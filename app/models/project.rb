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

  def add_collaborator(account)
    self.collaborations.create(:account => account)
    if @collaborator_ids
      @collaborator_ids.push account.id
      @collaborator_ids.uniq!
    end
  end

  def remove_collaborator(account)
    self.collaborations.owned_by(account).first.destroy
    @collaborator_ids -= [account.id] if @collaborator_ids
  end

  def add_document(document)
    self.project_memberships.create(:document => document)
  end

  def document_ids
    @document_ids ||= project_memberships.map {|m| m.document_id }
  end

  def collaborator_ids
    @collaborator_ids ||= collaborations.map {|m| m.account_id }
  end

  # How many annotations belong to documents belonging to this project?
  # How many of those annotations are accessible to a given account?
  def annotation_count(account=nil)
    account ||= self.account
    @annotation_count ||= Annotation.accessible(account).count(
      {:conditions => {:document_id => document_ids}}
    )
  end

  def to_json(opts={})
    attributes.merge(
      :account_full_name  => account_full_name,
      :annotation_count   => annotation_count(opts[:account]),
      :document_ids       => document_ids,
      :collaborator_ids   => collaborator_ids
    ).to_json
  end

end