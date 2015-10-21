# An **Entity**, for our purposes, is a piece of information either about or
# contained by a document (i.e., it may have a location within the document's
# text.) Each valid kind of entity must be whitelisted.
class Entity < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Store::EntityResource

  DEFAULT_RELEVANCE = 0.0

  ALL_CAPS = /\A[A-Z0-9\s.]+\Z/

  belongs_to :document
  belongs_to :account
  belongs_to :organization
  validates  :kind, :inclusion=>{ :in => DC::VALID_KINDS }
  validates  :value, :presence=>true
  text_attr  :value

  scope :kind, lambda {|kind| where( :kind => kind ) }

  def self.normalize_kind(string)
    DC::CALAIS_MAP[string.gsub(/\s+/,'').underscore.to_sym]
  end

  # Truncate and titlize the value, if necessary.
  def self.normalize_value(string)
    string = string[0...255]
    return string unless string.length > 5 && string.match(ALL_CAPS)
    string.titleize
  end

  def self.search_in_documents(kind, value, ids)
    return [] if value.nil?
    self.includes(:document).references(:document).where([
      "document_id in (?) and kind = ? and lower(value) like lower('%#{Entity.connection.quote_string(value)}%')", ids, kind
    ])
  end

  # Merge this entity with another of the "same" entity for the same document.
  # Needs to happen when the pass the document's text to Calais in chunks.
  def merge(entity)
    self.relevance = (self.relevance + entity.relevance) / 2.0
    @split_occurrences = self.split_occurrences + entity.split_occurrences
    self.occurrences = Occurrence.to_csv(@split_occurrences)
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

  def value=(val)
    write_attribute :value, val[0...255]
  end

  def as_json(options={})
    data = {
     'id'           => id,
     'document_id'  => document_id,
     'kind'         => kind,
     'value'        => value,
     'relevance'    => relevance,
     'occurrences'  => occurrences
    }
    data['excerpts'] = excerpts(150, self.pages.limit(200) ) if options[:include_excerpts]
    data
  end

  def canonical
    {
      'kind'      => kind,
      'value'     => value,
      'relevance' => relevance
    }
  end

end
