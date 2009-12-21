# Annotations are still in limbo -- not yet editable in the viewer.
class Annotation < ActiveRecord::Base

  include DC::Store::DocumentResource

  belongs_to :document

  validates_presence_of :title, :page_number

  before_validation :ensure_title

  named_scope :search_content, lambda { |query|
    {:conditions => ["to_tsvector('english', content) @@ plainto_tsquery(?)", query]}
  }

  def page
    document.pages.find_by_page_number(page_number)
  end

  def canonical
    data = {'id' => id, 'page' => page_number, 'title' => title, 'content' => content}
    data['location'] = {'image' => location} if location
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
