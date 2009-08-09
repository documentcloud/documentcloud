# NB: Doesn't inherit from ActiveRecord::Base ... yet.
class Document
  
  # Attributes for standard metadata:
  attr_accessor :author, :created_at, :date, :full_text, :language, 
                :organization, :summary, :title 
  
  # Attributes for internal use:
  attr_accessor :rdf, :metadata
  
  # OpenCalais-specific attributes:
  attr_accessor :calais_signature, :calais_request_id
  
  # Reproduce would-be attributes of a made-up document entry.
  # Optionally specify the top N entities to return.
  def self.generate_fake_entry(num_metadata=10)
    {
      'title'         => Faker::Lorem.words(rand(10) + 2).join(' '),
      'author'        => Faker::Name.name,
      'organization'  => Faker::Company.name,
      'created_at'    => rand(600).days.from_now,
      'summary'       => Faker::Lorem.paragraph,
      'metadata'      => Array.new(num_metadata).map { Metadatum.generate_fake }
    }
  end
  
  def initialize
    @metadata = []
  end
  
end