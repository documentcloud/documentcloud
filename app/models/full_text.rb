# The Full Text table keeps the full text column off of the document, keeping
# fast document lookups fast.
class FullText < ActiveRecord::Base

  include DC::Store::DocumentResource

  set_table_name "full_text"

  belongs_to :document

  # The first 255 characters of the text.
  def summarize
    text[0...1000].gsub(/\s+/, ' ').mb_chars[0...255]
  end

  # Refresh the full text index from the contents of the document's pages.
  def refresh
    update_attribute :text, document.combined_page_text
    DC::Store::AssetStore.new.save_full_text(document, access)
  end

end