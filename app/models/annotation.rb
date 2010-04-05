class Annotation < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Access

  belongs_to :document

  validates_presence_of :title, :page_number

  before_validation :ensure_title

  named_scope :accessible, lambda { |account|
    access = []
    access << "(annotations.access = #{PUBLIC})"
    access << "(annotations.access = #{PRIVATE} and annotations.account_id = #{account.id})" if account
    {:conditions => "(#{access.join(' or ')})"}
  }

  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  named_scope :in_order, {:order => :page_number}

  searchable do
    text :title, :boost => 2.0
    text :content
  end

  def self.counts_for_documents(owner, docs)
    doc_ids = docs.map {|doc| doc.id }
    self.count(:conditions => {:account_id => owner.id, :document_id => doc_ids}, :group => 'document_id')
  end

  def page
    document.pages.find_by_page_number(page_number)
  end

  def canonical
    data = {'id' => id, 'page' => page_number, 'title' => title, 'content' => content}
    data['location'] = {'image' => location} if location
    data['access'] = 'private' if access == PRIVATE
    data
  end

  def to_json(opts={})
    canonical.merge({'document_id' => document_id}).to_json
  end


  private

  def ensure_title
    self.title = "Untitled Annotation" if title.blank?
  end

end
