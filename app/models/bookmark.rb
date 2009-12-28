# A bookmark saves a quick link to a specific page of a document.
class Bookmark < ActiveRecord::Base

  belongs_to :account

  validates_presence_of :title, :document_id, :account_id, :page_number

  validates_uniqueness_of :page_number, :scope => [:document_id, :account_id]

  named_scope :alphabetical, {:order => 'title'}

  # JSON representation of a bookmark. (not exposed through any API, yet)
  def to_json(opts={})
    {:id => id, :title => title, :document_id => document_id, :page_number => page_number}.to_json
  end

  # The document that this bookmark references.
  def document
    Document.find(document_id)
  end

  # The complete URL to the correct page in a document viewer.
  def document_viewer_url
    document.document_viewer_url + "#document/p#{page_number}"
  end

end