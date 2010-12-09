class Section < ActiveRecord::Base

  include DC::Store::DocumentResource

  belongs_to :document

  validates_presence_of :title, :page_number

  validates_uniqueness_of :page_number, :scope => :document_id

  # The canonical JSON representation of a section.
  def canonical
    {'title' => title, 'page' => page_number}
  end

  def canonical_url
    document.canonical_url(:html) + '#document/p' + page_number.to_s
  end

end
