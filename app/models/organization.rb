# A (News or Watchdog) organization with the power to create DocumentCloud
# accounts and upload documents.
class Organization < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include DC::Access

  attr_accessor :document_count, :note_count

  has_many :accounts, :dependent => :destroy

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :slug, :with => DC::Validators::SLUG

  # Retrieve the names of the organizations for the result set of documents.
  def self.names_for_documents(docs)
    ids = docs.map {|doc| doc.organization_id }.uniq
    self.all(:conditions => {:id => ids}, :select => 'id, name').inject({}) do |hash, org|
      hash[org.id] = org.name; hash
    end
  end

  # Retrieve the list of organizations with public documents, including counts.
  def self.listed
    filter = {:group => 'organization_id', :conditions => {:access => PUBLIC}}
    public_doc_counts   = Document.count filter
    public_note_counts  = Annotation.count filter
    orgs = self.all(:conditions => {:id => public_doc_counts.keys, :demo => false})
    orgs.each do |org|
      org.document_count = public_doc_counts[org.id]  || 0
      org.note_count     = public_note_counts[org.id] || 0
    end
    orgs
  end

  # How many documents have been uploaded across the whole organization?
  def document_count
    @document_count ||= Document.count(:conditions => {:organization_id => id})
  end

  # The list of all administrator emails in the organization.
  def admin_emails
    self.accounts.admin.all(:select => [:email]).map {|acc| acc.email }
  end

  def to_json(options = nil)
    {'name'           => name,
     'slug'           => slug,
     'demo'           => demo,
     'id'             => id,
     'document_count' => document_count,
     'note_count'     => note_count}.to_json
  end

end
