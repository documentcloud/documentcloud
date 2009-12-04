class FullText < ActiveRecord::Base

  include DC::Store::DocumentResource

  set_table_name "full_text"

  belongs_to :document

  named_scope :search_text, lambda { |query|
    {:conditions => ["to_tsvector('english', text) @@ plainto_tsquery(?)", query]}
  }

  def summary
    text[0...1000].gsub(/\s+/, ' ')[0...255]
  end

end