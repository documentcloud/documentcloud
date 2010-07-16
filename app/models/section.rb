class Section < ActiveRecord::Base

  include DC::Store::DocumentResource

  belongs_to :document

  validates_presence_of :title, :start_page, :end_page

  def validate
    validate_page_range
  end

  # The canonical JSON representation of a section.
  def canonical
    {'title' => title, 'pages' => page_range}
  end

  # The string-formatted page range of this section.
  def page_range
    "#{start_page}-#{end_page}"
  end

  def canonical_url
    document.canonical_url(:html) + '#document/p' + start_page.to_s
  end


  private

  # Sections begin before they end.
  def validate_page_range
    backwards = !end_page || end_page < start_page
    errors.add_to_base "The section cannot end before it begins." if backwards
  end

end
