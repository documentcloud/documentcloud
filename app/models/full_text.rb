class FullText < ActiveRecord::Base
  
  include DC::Store::DocumentResource
  
  set_table_name "full_text"
  
  belongs_to :document
  
  named_scope :search_text, lambda { |query|
    {:conditions => ["to_tsvector('english', text) @@ plainto_tsquery(?)", query]}
  }
  
end