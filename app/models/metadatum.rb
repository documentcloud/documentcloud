# A metadatum, for our purposes, is a piece of metadata either about or 
# contained by a document (i.e., it may have a location within the document's
# text.) Each valid kind of metadata must be whitelisted.
class Metadatum < ActiveRecord::Base
  
  include DC::Store::DocumentResource
    
  DEFAULT_RELEVANCE = 0.0
  
  belongs_to :document
  
  validates_inclusion_of :kind, :in => DC::VALID_KINDS
  
  named_scope :search_value, lambda { |query|
    {:conditions => ["to_tsvector('english', value) @@ plainto_tsquery(?)", query]}
  }
  
  named_scope :categories, {:conditions => {:kind => 'category'}}
  
  def self.acceptable_kind?(kind)
    DC::CALAIS_KINDS.include? kind.underscore.to_sym
  end
  
  def split_occurrences
    Occurrence.from_csv(self.occurrences)
  end
  
  # A Metadatum is considered to be textual if it occurs in the body of the text.
  def textual?
    occurrences.present?
  end
  
  def to_json(options=nil)
    super(options.merge({:only => [:id, :document_id, :kind, :value, :relevance]}))
  end
  
end