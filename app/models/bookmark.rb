class Bookmark < ActiveRecord::Base

  belongs_to :account

  validates_presence_of :title, :document_id, :account_id, :page_number

  validates_uniqueness_of :page_number, :scope => [:document_id, :account_id]

  default_scope :order => 'title'

  def to_json(opts={})
    {:id => id, :title => title, :document_id => document_id, :page_number => page_number}.to_json
  end

  def document
    Document.find(document_id)
  end

  def document_viewer_url
    document.document_viewer_url + "#view=Document&page=#{page_number}"
  end

end