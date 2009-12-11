class FullText < ActiveRecord::Base

  include DC::Store::DocumentResource

  set_table_name "full_text"

  belongs_to :document

  named_scope :search_text, lambda { |query|
    {:conditions => ["to_tsvector('english', text) @@ plainto_tsquery(?)", query]}
  }

  def self.highlights(documents, search_phrase)
    sql = "select document_id, ts_headline('english', full_text.text, plainto_tsquery('#{search_phrase}'), 'minWords=50,maxWords=60,maxFragments=1') as highlight from full_text where full_text.document_id in (#{documents.map(&:id).join(',')})"
    connection.select_all(sql).inject({}) {|h, res| h[res['document_id'].to_i] = res['highlight']; h }
  end

  def summary
    text[0...1000].gsub(/\s+/, ' ')[0...255]
  end

end