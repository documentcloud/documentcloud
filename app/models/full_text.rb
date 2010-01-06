# The Full Text table keeps the full text column off of the document, keeping
# fast document lookups fast.
class FullText < ActiveRecord::Base

  include DC::Store::DocumentResource

  set_table_name "full_text"

  belongs_to :document

  # Run a search across the text of the document, using Postgres' native FTS.
  named_scope :search_text, lambda { |query|
    {:conditions => ["to_tsvector('english', text) @@ plainto_tsquery(?)", query]}
  }

  # Generate the highlighted excerpt of the full text for a given search phrase.
  def self.highlights(documents, search_phrase)
    sql = "select document_id, ts_headline('english', full_text.text, plainto_tsquery('#{search_phrase}'), 'minWords=50,maxWords=60,maxFragments=1') as highlight from full_text where full_text.document_id in (#{documents.map(&:id).join(',')})"
    connection.select_all(sql).inject({}) {|h, res| h[res['document_id'].to_i] = res['highlight']; h }
  end

  # The default summary of a document is the first 255 characters of the text.
  def summary
    text[0...1000].gsub(/\s+/, ' ')[0...255]
  end

  # Refresh the full text index from the contents of the document's pages.
  def refresh
    update_attribute :text, document.combined_page_text
    DC::Store::AssetStore.new.save_full_text(document, access)
  end

end