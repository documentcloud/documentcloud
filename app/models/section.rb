class Section < ActiveRecord::Base

  include DC::Store::DocumentResource

  belongs_to :document
  belongs_to :organization
  belongs_to :account

  validates  :title,       :presence=>true
  validates  :page_number, :presence=>true, :uniqueness=>{ :scope => :document_id }

  # Sanitizations
  text_attr :title

  # The canonical JSON representation of a section.
  def canonical
    {'title' => title, 'page' => page_number}
  end

  def canonical_url
    document.canonical_url(:html) + '#document/p' + page_number.to_s
  end

end
