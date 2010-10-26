class Annotation < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Access

  belongs_to :document
  belongs_to :account # NB: This account is not the owner of the document.
                      #     Rather, it is the author of the annotation.
  
  attr_accessor :author_name
  
  validates_presence_of :title, :page_number

  before_validation :ensure_title

  named_scope :accessible, lambda { |account, include_exclusive|
    access = []
    access << "(annotations.access = #{PUBLIC})"
    access << "(annotations.access = #{EXCLUSIVE})" if account && include_exclusive
    access << "(annotations.access = #{PRIVATE} and annotations.account_id = #{account.id})" if account
    {:conditions => "(#{access.join(' or ')})"}
  }
  
  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  named_scope :after, lambda {|doc_id, page_number|
    {:conditions => ["document_id = ? and page_number > ?", document.id, insert_page_at.to_i]}
  }

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
    self.accessible(account, false).count(:conditions => {:document_id => doc_ids}, :group => 'document_id')
  end

  def self.author_names(doc, current_account)
    accounts = Account.find(:all, :joins => [:annotations], 
                            :select => "accounts.id, accounts.first_name, accounts.last_name", 
                            :group => "accounts.id, first_name, last_name", 
                            :conditions => ["annotations.document_id = ?", doc.id])
    accounts.inject({}) do |m, a| 
      m[a.id] = a.full_name if a.full_name != current_account.full_name
      m
    end
  end
  
  def page
    document.pages.find_by_page_number(page_number)
  end

  def canonical_url
    document.canonical_url(:html) + '#document/' + page_number.to_s
  end
  
  def canonical
    data = {'id' => id, 'page' => page_number, 'title' => title, 'content' => content}
    data['location'] = {'image' => location} if location
    data['access'] = 'private' if access == PRIVATE
    data['access'] = 'exclusive' if access == EXCLUSIVE
    data['access'] = 'public' if access == PUBLIC
    data['author'] = author_name if author_name
    data
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
