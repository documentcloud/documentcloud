class Annotation < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Access

  belongs_to :document

  validates_presence_of :title, :page_number

  before_validation :ensure_title

  named_scope :search_content, lambda { |query|
    {:conditions => ["annotations_content_vector @@ plainto_tsquery(?)", query]}
  }

  named_scope :accessible, lambda { |account|
    access = []
    access << "(annotations.access = #{PUBLIC})"
    access << "(annotations.access = #{PRIVATE} and annotations.account_id = #{account.id})" if account
    {:conditions => "(#{access.join(' or ')})"}
  }

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
    canonical.to_json
  end


  private

  def ensure_title
    self.title = "Untitled Annotation" if title.blank?
  end

end
