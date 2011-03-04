class Annotation < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Access

  belongs_to :document
  belongs_to :account # NB: This account is not the owner of the document.
                      #     Rather, it is the author of the annotation.

  attr_accessor :author

  validates_presence_of :title, :page_number

  before_validation :ensure_title

  after_create  :reset_public_note_count
  after_destroy :reset_public_note_count

  # Sanitizations:
  text_attr :title
  html_attr :content

  named_scope :accessible, lambda { |account|
    access = []
    access << "(annotations.access = #{PUBLIC})"
    access << "((annotations.access = #{EXCLUSIVE}) and annotations.organization_id = #{account.organization_id})" if account
    access << "(annotations.access = #{PRIVATE} and annotations.account_id = #{account.id})" if account
    access << "((annotations.access = #{EXCLUSIVE}) and annotations.document_id in (?))" if account && account.shared_document_ids.present?
    conditions = ["(#{access.join(' or ')})"]
    conditions.push(account.shared_document_ids) if account && account.shared_document_ids.present?
    {:conditions => conditions}
  }

  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  named_scope :unrestricted, :conditions => {:access => PUBLIC}

  searchable do
    text :title, :boost => 2.0
    text :content

    integer :document_id
    integer :account_id
    integer :organization_id
    integer :access
    time    :created_at
  end

  def self.counts_for_documents(account, docs)
    doc_ids = docs.map {|doc| doc.id }
    self.accessible(account).count(:conditions => {:document_id => doc_ids}, :group => 'document_id')
  end

  def self.author_info(doc, current_account=nil)
    account_sql = <<-EOS
      SELECT DISTINCT accounts.id, accounts.first_name, accounts.last_name,
                      organizations.name as organization_name
      FROM accounts
      INNER JOIN annotations   ON annotations.account_id = accounts.id
      INNER JOIN organizations ON organizations.id = accounts.organization_id
      WHERE (annotations.document_id = #{doc.id})
    EOS
    accounts = {}
    rows = Account.connection.select_all(account_sql)
    rows.each do |a|
      id = a['id'].to_i
      accounts[id] = {
        :full_name         => "#{a['first_name']} #{a['last_name']}",
        :organization_name => a['organization_name'],
        :account_id        => id
        :owns_note         => current_account && current_account.id == id
      }
    end
    accounts
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

  def canonical_url
    document.canonical_url(:html) + '#document/' + page_number.to_s
  end

  def canonical
    data = {'id' => id, 'page' => page_number, 'title' => title, 'content' => content, :access => access_name}
    data['location'] = {'image' => location} if location
    if author
      data.merge!({
        'author'              => author[:full_name],
        'author_id']          => author[:account_id],
        'owns_note']          => author[:owns_note],
        'author_organization' => author[:organization_name]
      })
    end
    data
  end

  def reset_public_note_count
    return unless access == PUBLIC
    document.reset_public_note_count
  end

  def to_json(opts={})
    canonical.merge({
      'document_id'     => document_id,
      'account_id'      => account_id,
      'organization_id' => organization_id
    }).to_json
  end

  private

  def ensure_title
    self.title = "Untitled Annotation" if title.blank?
  end

end
