class Page < ActiveRecord::Base
  
  include DC::Store::DocumentResource
  
  belongs_to :document
  
  validates_numericality_of :page_number, :greater_than_or_equal_to => 1
  
  named_scope :search_text, lambda { |query|
    {:conditions => ["to_tsvector('english', text) @@ plainto_tsquery(?)", query]}
  }
  
end