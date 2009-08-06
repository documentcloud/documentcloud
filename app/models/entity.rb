# An entity, for our purposes, is a piece of metadata either about or 
# contained by a document (i.e., it may have a location within the document's
# text.) Entities have a whitelisted type, or list of acceptable types.
class Entity
  
  attr_reader :value
  attr_accessor :type, :position, :document, :relevance
  
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
  
  # Generate a fake entity for testing purposes.
  # TODO: Expand this to look into a document's full text and pull out a string,
  # with its position.
  def self.generate_fake_entity
    value     = Faker::Lorem.words(1)
    type      = CALAIS_TYPES[rand(CALAIS_TYPES.length)]
    relevance = rand(100/100.0)
    Entity.new(value, type, relevance)
  end
  
  def initialize(value, type, relevance, document=nil, position=nil)
    @value, @type, @relevance = value, type, relevance
    @document, @position = document, position
  end
  
end