# An **Entity**, for our purposes, is a piece of information either about or
# contained by a document (i.e., it may have a location within the document's
# text.) Each valid kind of entity must be whitelisted.
class Entity < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Store::EntityResource

  DEFAULT_RELEVANCE = 0.0

  belongs_to :document

  validates_inclusion_of :kind, :in => DC::VALID_KINDS

  named_scope :search_value, lambda { |query|
    {:conditions => ["metadata_value_vector @@ plainto_tsquery(?)", query]}
  }

  # We don't pay attention to all kinds of Calais-generated entities, just
  # most of them. Checks the whitelist.
  def self.acceptable_kind?(kind)
    !!DC::CALAIS_MAP[kind.underscore.to_sym]
  end

  # The pages on which this entity occurs within the document.
  def pages(occurs=split_occurrences)
    return [] unless textual?
    super(occurs)
  end

  # An Entity is considered to be textual if it occurs in the body of the text.
  def textual?
    occurrences.present?
  end

  def to_json(options=nil)
    {'id'           => id,
     'document_id'  => document_id,
     'kind'         => kind,
     'value'        => value,
     'relevance'    => relevance
    }.to_json
  end

  def canonical
    {
      'kind'      => kind,
      'value'     => value,
      'relevance' => relevance
    }
  end

end