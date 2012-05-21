class Annotation < ActiveRecord::Base

  include DC::Access

  belongs_to :document
  belongs_to :commenter # NB: This account is not the owner of the document.
                        #     Rather, it is the author of the annotation.

  has_many :project_memberships, :through => :document

  attr_accessor :author, :comments

  validates_presence_of :title, :page_number
  validates_presence_of :organization_id, :commenter_id, :document_id, :access

  before_validation :ensure_title
  before_create :before_validation_on_create

  def before_validation_on_create
    self.document_id      = document.id
    self.organization_id  = organization_id || document.organization_id
    self.commenter_id     = commenter_id || document.account.commenter_id
    self.access           = access || document.access
  end

  after_create  :reset_public_note_count
  after_destroy :reset_public_note_count

  # Sanitizations:
  text_attr :title
  html_attr :content

  # Access permissions for annotations are enforced 
  named_scope :accessible, lambda { |account|
    has_shared = account && account.accessible_project_ids.present?
    access = []
    access << "(annotations.access = #{PUBLIC})"
    access << "((annotations.access = #{EXCLUSIVE}) and annotations.organization_id = #{account.organization_id})" if account
    access << "(annotations.access = #{PRIVATE} and annotations.commenter_id = #{account.commenter_id})" if account
    access << "((annotations.access = #{EXCLUSIVE}) and memberships.document_id = annotations.document_id)" if has_shared
    opts = {:conditions => ["(#{access.join(' or ')})"], :readonly => false}
    if has_shared
      opts[:joins] = <<-EOS
        left outer join
        (select distinct document_id from project_memberships
          where project_id in (#{account.accessible_project_ids.join(',')})) as memberships
        on memberships.document_id = annotations.document_id
      EOS
    end
    opts
  }

  named_scope :owned_by, lambda { |account|
    {:conditions => {:commenter_id => account.commenter_id}}
  }

  named_scope :unrestricted, :conditions => {:access => PUBLIC}

  # Annotations are not indexed for the time being.

  # searchable do
  #   text :title, :boost => 2.0
  #   text :content
  # 
  #   integer :document_id
  #   integer :account_id
  #   integer :organization_id
  #   integer :access
  #   time    :created_at
  # end

  def self.counts_for_documents(account, docs)
    doc_ids = docs.map {|doc| doc.id }
    self.accessible(account).count(:conditions => {:document_id => doc_ids}, :group => 'annotations.document_id')
  end

  def self.populate_author_info(notes, current_account=nil)
    return if notes.empty?
    account_sql = <<-EOS
      SELECT DISTINCT accounts.id, accounts.first_name, accounts.last_name,
                      accounts.role, organizations.name as organization_name
      FROM accounts
      INNER JOIN annotations   ON annotations.commenter_id = accounts.commenter_id
      INNER JOIN organizations ON organizations.id = accounts.organization_id
      WHERE annotations.id in (#{notes.map(&:id).join(',')})
    EOS
    rows = Account.connection.select_all(account_sql)
    account_map = rows.inject({}) do |memo, acc| 
      memo[acc['id'].to_i] = acc unless acc.nil?
      memo
    end
    notes.each do |note|
      author = account_map[note.commenter_id]
      note.author = {
        :full_name         => author ? "#{author['first_name']} #{author['last_name']}" : "Unattributed",
        :account_id        => note.commenter_id,
        :owns_note         => current_account && current_account.id == note.commenter_id
      }
      if author && [Account::ADMINISTRATOR, Account::CONTRIBUTOR, Account::FREELANCER].include?(author['role'].to_i)
        note.author[:organization_name] = author['organization_name']
      end
    end
  end
  
  def self.populate_comment_info(notes, current_account)
    return if notes.empty?
    unsorted_comments = Comment.all(:conditions=>{ :annotation_id => notes.map(&:id) })
    grouped_comments = unsorted_comments.group_by{ |c| c.annotation_id }
    grouped_comments.each do |note_id, comments|
      notes.select{ |n| n.id == note_id }.first.comments = comments
    end
    notes
  end

  def self.public_note_counts_by_organization
    self.unrestricted.count({
      :joins      => [:document],
      :conditions => ["documents.access = ?", PUBLIC],
      :group      => 'annotations.organization_id'
    })
  end

  def page
    document.pages.find_by_page_number(page_number)
  end

  def access_name
    ACCESS_NAMES[access]
  end
  
  def cacheable?
    access == PUBLIC && document.cacheable?
  end

  def canonical_url
    document.canonical_url(:html) + '#document/' + page_number.to_s
  end

  def canonical_cache_path
    "/documents/#{document.id}/annotations/#{id}.js"
  end
  
  def canonical(opts={})
    data = {'id' => id, 'page' => page_number, 'title' => title, 'content' => content, :access => access_name}
    data['location'] = {'image' => location} if location
    data['image_url'] = document.page_image_url_template if opts[:include_image_url]
    data['published_url'] = document.published_url || document.document_viewer_url(:allow_ssl => true) if opts[:include_document_url]
    if author
      data.merge!({
        'author'              => author[:full_name],
        'owns_note'           => author[:owns_note],
        'author_organization' => author[:organization_name]
      })
    end
    data.merge!({ 'comments' => comments }) if comments
    data
  end

  def reset_public_note_count
    document.reset_public_note_count
  end

  def to_json(opts={})
    canonical.merge({
      'document_id'     => document_id,
      'account_id'      => commenter_id,
      'organization_id' => organization_id
    }).to_json
  end

  private

  def ensure_title
    self.title = "Untitled Annotation" if title.blank?
  end

end
