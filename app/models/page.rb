# A single page of a document has its own text saved separately, so that
# in-document searches can be performed.
class Page < ActiveRecord::Base

  include DC::Store::DocumentResource
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods

  belongs_to :document, :counter_cache => :page_count

  validates_numericality_of :page_number, :greater_than_or_equal_to => 1

  named_scope :search_text, lambda { |query|
    {:conditions => ["text_vector @@ plainto_tsquery(?)", query], :select => [:page_number]}
  }

  delegate :pages_path, :to => :document

  default_scope :order => 'page_number'

  before_update :track_text_changes

  after_update :refresh_full_text_index

  # Ex: docs/1011/pages/21_large.gif
  def image_path(size)
    File.join(document.pages_path, "#{document.slug}-p#{page_number}-#{size}.gif")
  end

  # Ex: docs/1011/pages/21.txt
  def text_path
    File.join(document.pages_path, "#{document.slug}-p#{page_number}.txt")
  end

  def authorized_image_url(size)
    DC::Store::AssetStore.new.authorized_url(image_path(size))
  end


  private

  # Make sure that HTML never gets written into the plain text contents.
  # TODO: Should we go back to Calais and blow away metadata for little edits?
  def track_text_changes
    return true unless text_changed?
    self.text = strip_tags(text)
    DC::Store::AssetStore.new.save_page_text(self, access)
  end

  # When page text changes, we need to update the document's full text index.
  def refresh_full_text_index
    document.full_text.refresh
  end

end