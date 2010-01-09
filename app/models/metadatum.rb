# A metadatum, for our purposes, is a piece of metadata either about or
# contained by a document (i.e., it may have a location within the document's
# text.) Each valid kind of metadata must be whitelisted.
class Metadatum < ActiveRecord::Base

  include DC::Store::DocumentResource

  DEFAULT_RELEVANCE = 0.0

  belongs_to :document

  validates_inclusion_of :kind, :in => DC::VALID_KINDS

  named_scope :search_value, lambda { |query|
    {:conditions => ["metadata_value_vector @@ plainto_tsquery(?)", query]}
  }

  named_scope :categories, {:conditions => {:kind => 'category'}}

  # We don't pay attention to all kinds of Calais-generated metadata, just
  # most of them. Checks the whitelist.
  def self.acceptable_kind?(kind)
    !!DC::CALAIS_MAP[kind.underscore.to_sym]
  end

  # Instead of having a separate table for occurrences, we serialize them to
  # a CSV format on each Metadatum. Deserializes.
  def split_occurrences
    Occurrence.from_csv(self.occurrences)
  end

  # A Metadatum is considered to be textual if it occurs in the body of the text.
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

end