# An **Entity**, for our purposes, is a piece of information either about or
# contained by a document (i.e., it may have a location within the document's
# text.) Each valid kind of entity must be whitelisted.
class Entity < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Store::EntityResource

  DEFAULT_RELEVANCE = 0.0

  belongs_to :document

  validates_inclusion_of :kind, :in => DC::VALID_KINDS

  named_scope :kind, lambda {|kind| {:conditions => {:kind => kind}} }

  # We don't pay attention to all kinds of Calais-generated entities, just
  # most of them. Checks the whitelist.
  def self.acceptable_kind?(kind)
    !!DC::CALAIS_MAP[kind.underscore.to_sym]
  end

  def self.search_in_documents(kind, value, ids)
    entities = self.all(:conditions => {:document_id => ids, :kind => kind, :value => value})
    if entities.empty?
      entities = self.all({:conditions => [
        "document_id in (?) and kind = ? and value ilike '%#{Entity.connection.quote_string(value)}%'", ids, kind
      ]})
    end
    entities
  end

  # The pages on which this entity occurs within the document.
  def pages(occurs=split_occurrences, options={})
    return [] unless textual?
    super(occurs, options)
  end

  # An Entity is considered to be textual if it occurs in the body of the text.
  def textual?
    occurrences.present?
  end

  def value=(val)
    write_attribute :value, val.mb_chars[0...255].to_s
  end

  def to_json(options={})
    data = {
     'id'           => id,
     'document_id'  => document_id,
     'kind'         => kind,
     'value'        => value,
     'relevance'    => relevance
    }
    data['pages']   =  pages(split_occurrences, :limit => 200).map {|p| p.page_number } if options[:include_pages]
    data.to_json
  end

  def canonical
    {
      'kind'      => kind,
      'value'     => value,
      'relevance' => relevance
    }
  end

end