# A metadatum, for our purposes, is a piece of metadata either about or 
# contained by a document (i.e., it may have a location within the document's
# text.) Metadata have a whitelisted type, or list of acceptable types.
class Metadatum
  
  attr_accessor :type, :instances, :relevance, :value, :calais_hash
  
  CALAIS_TYPES = [
    :city, :company, :continent, :country, :email_address, :facility, 
    :holiday, :industry_term, :natural_feature, :organization, :person,
    :position, :product, :provice_or_state, :published_medium, :region,
    :technology, :url
  ]
  
  # TODO: Think about modeling journalist-provided attributes in the same
  # way as the rest of the metadata we're gathering. Our metadata system
  # should be able to handle things like title, author, news_org,
  # published_date, provenance, etc.
  
  def self.acceptable_type?(type)
    CALAIS_TYPES.include? type.underscore.to_sym
  end
  
  # Generate a fake Metadatum for testing purposes.
  # TODO: Expand this to look into a document's full text and pull out a string,
  # with its instances.
  def self.generate_fake
    value     = Faker::Lorem.words(1).first
    type      = CALAIS_TYPES[rand(CALAIS_TYPES.length)]
    relevance = rand(100/100.0)
    Metadatum.new(value, type, relevance)
  end
  
  def initialize(value, type, relevance, instances=nil)
    @value, @type, @relevance, @instances = value, type, relevance, instances
  end
  
  def primary_key
    raise "Cannot produce key without Calais hash." if !@calais_hash
    @calais_hash
  end
  
  def to_hash
    {
      'value' => @value,
      'type' => @type,
      'relevance' => @relevance,
      'instances' => Instance.to_csv(instances)
    }
  end
  
end