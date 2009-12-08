class Annotation < ActiveRecord::Base

  include DC::Store::DocumentResource

  belongs_to :document

  validates_presence_of :title, :page_number, :access

  named_scope :search_content, lambda { |query|
    {:conditions => ["to_tsvector('english', content) @@ plainto_tsquery(?)", query]}
  }

  def page
    document.pages.find_by_page_number(page_number)
  end

  def canonical
    data = {'page' => page_number, 'title' => title, 'content' => content}
    data['location'] = {'image' => location} if location
    data
  end

end
