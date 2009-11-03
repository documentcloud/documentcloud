class Page < ActiveRecord::Base
  
  include DC::Store::DocumentResource
  
  belongs_to :document, :counter_cache => :page_count
  
  validates_numericality_of :page_number, :greater_than_or_equal_to => 1
  
  named_scope :search_text, lambda { |query|
    {:conditions => ["to_tsvector('english', text) @@ plainto_tsquery(?)", query]}
  }
  
  delegate :pages_path, :to => :document
  
  default_scope :order => 'page_number'
  
  # Ex: docs/1011/pages/21_large.gif
  def image_path(size)
    File.join(document.pages_path, "#{document.slug}-p#{page_number}-#{size}.gif")
  end
  
  # Ex: docs/1011/pages/21.txt
  def text_path
    File.join(document.pages_path, "#{document.slug}-p#{page_number}.txt")
  end
  
end