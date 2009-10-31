# A metadatum, for our purposes, is a piece of metadata either about or 
# contained by a document (i.e., it may have a location within the document's
# text.) Metadata have a whitelisted kind, or list of acceptable kinds.
class Metadatum < ActiveRecord::Base
  
  include DC::Store::DocumentResource
  
  VALID_KINDS = DC::CALAIS_KINDS.map(&:to_s) + ['category']
  
  DEFAULT_RELEVANCE = 0.0
  
  belongs_to :document
  
  validates_inclusion_of :kind, :in => VALID_KINDS
  
  named_scope :search_value, lambda { |query|
    {:conditions => ["to_tsvector('english', value) @@ ?", query]}
  }
  
  def self.acceptable_kind?(kind)
    DC::CALAIS_KINDS.include? kind.underscore.to_sym
  end
  
  # A Metadatum is considered to be textual if it occurs in the body of the text.
  def textual?
    !occurrences.empty?
  end
  
  def to_json(opts={})
    { 'id'          => id,
      'document_id' => document_id,
      'kind'        => kind,
      'value'       => value,
      'relevance'   => relevance
    }.to_json
  end
  
end