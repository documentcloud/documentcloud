# A metadatum, for our purposes, is a piece of metadata either about or 
# contained by a document (i.e., it may have a location within the document's
# text.) Metadata have a whitelisted type, or list of acceptable types.
class Metadatum
  
  attr_accessor :type, :occurrences, :relevance, :value, :calais_hash, :document_id
  
  # The whitelisted types of metadata from OpenCalais that we're interested in.
  # Keep this list in sync with the mapping in metadatum.js, please.
  CALAIS_TYPES = [
    :city, :company, :continent, :country, :email_address, :facility, 
    :holiday, :industry_term, :natural_feature, :organization, :person,
    :position, :product, :province_or_state, :published_medium, :region,
    :technology, :url
  ]
  
  # TODO: Think about modeling journalist-provided attributes in the same
  # way as the rest of the metadata we're gathering. Our metadata system
  # should be able to handle things like title, author, news_org,
  # published_date, provenance, etc.
  
  def self.acceptable_type?(type)
    CALAIS_TYPES.include? type.underscore.to_sym
  end

  # Recreate a Metadatum object from it's freeze-dried counterpart on disk.
  # Performs the inverse of the to_hash serialization method below.
  def self.from_hash(data)
    Metadatum.new(
      data['value'],
      data['type'],
      data['relevance'].to_f,
      data['document_id'],
      {
        :occurrences => Occurrence.from_csv(data['occurrences']),
        :calais_hash => data['calais_hash']
      }
    )
  end
  
  # Generate a fake Metadatum for testing purposes.
  # TODO: Expand this to look into a document's full text and pull out a string,
  # with its occurrences.
  # def self.generate_fake
  #   value     = Faker::Lorem.words(1).first
  #   type      = CALAIS_TYPES[rand(CALAIS_TYPES.length)]
  #   relevance = rand(100/100.0)
  #   Metadatum.new(value, type, relevance)
  # end
  
  def initialize(value, type, relevance, document_id, opts={})
    @value, @type, @relevance, @document_id = value, type, relevance, document_id
    @occurrences = opts[:occurrences] || []
    @calais_hash = opts[:calais_hash]
  end
  
  # Totally hokey way to get a unique id. Think about what this should be.
  def id
    "#{@document_id}--#{@calais_hash || @value}"
  end
  
  # Return or find the document to which this metadatum belongs.
  # TODO: Think about moving the cached document into a per-request identity map
  # living on Document itself.
  def document
    @document ||= DC::Store::EntryStore.new.find(@document_id)
  end
  
  # A Metadatum is considered to be textual if it occurs in the body of the text.
  def textual?
    !@occurrences.empty?
  end
  
  def inspect
    "#<Metadatum #{type}:#{value}>"
  end
  
  def to_hash
    {
      'value' => @value,
      'type' => @type,
      'relevance' => @relevance,
      'document_id' => @document_id,
      'occurrences' => Occurrence.to_csv(@occurrences),
      'calais_hash' => @calais_hash
    }
  end
  
end