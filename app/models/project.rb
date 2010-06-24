# A Project, (or Folder, Bucket, Tag, Collection, Notebook, etc.) is a
# name under which to group a set of related documents, purely for
# organizational purposes.
class Project < ActiveRecord::Base

  belongs_to :account
  has_many :project_memberships, :dependent => :destroy
  has_many :project_sharings,    :dependent => :destroy
  has_many :documents,           :through => :project_memberships

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :account_id

  named_scope :alphabetical, {:order => :title}

  named_scope :accessible, lambda {|account|
    {:conditions => ['account_id = ? or id in (select project_id from project_sharings where account_id = ?)', account.id, account.id]}
  }

  delegate :full_name, :to => :account, :prefix => true

  attr_writer :annotation_count

  # Load all of the projects belonging to an account in one fell swoop.
  def self.load_for(account)
    self.accessible(account).all(:include => ['account', 'project_memberships', 'project_sharings'])
  end

  def share_with(account)
    self.project_sharings.create(:account => account)
  end

  def add_document(document)
    self.project_memberships.create(:document => document)
  end

  def document_ids
    @document_ids ||= project_memberships.map {|m| m.document_id }
  end

  def shared_account_ids
    @shared_account_ids ||= project_sharings.map {|m| m.account_id }
  end

  # How many annotations belong to documents belonging to this project?
  def annotation_count
    @annotation_count ||= Annotation.count(
      {:conditions => {:account_id => account_id, :document_id => document_ids}}
    )
  end

  def to_json(opts={})
    attributes.merge(
      :account_full_name  => account_full_name,
      :annotation_count   => annotation_count,
      :document_ids       => document_ids,
      :shared_account_ids => shared_account_ids
    ).to_json
  end

end