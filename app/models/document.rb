# NB: Doesn't inherit from ActiveRecord::Base ... yet.
class Document
  
  ENTRY_ATTRIBUTES = [:author, :created_at, :date, :language, :organization, 
                      :summary, :title, :calais_request_id]
                      
  TEMPORARY_ATTRIBUTES = [:full_text, :rdf, :metadata, :calais_signature]
  
  ATTRIBUTES = ENTRY_ATTRIBUTES + TEMPORARY_ATTRIBUTES
                      
  ATTRIBUTES.each {|a| attr_accessor a }
  
  def self.from_entry_hash(entry_hash)
    Document.new(entry_hash)
  end
  
  # Reproduce would-be attributes of a made-up document entry.
  # Optionally specify the top N entities to return.
  # def self.generate_fake_entry(num_metadata=10)
  #   {
  #     'title'         => Faker::Lorem.words(rand(10) + 2).join(' '),
  #     'author'        => Faker::Name.name,
  #     'organization'  => Faker::Company.name,
  #     'created_at'    => rand(600).days.from_now,
  #     'summary'       => Faker::Lorem.paragraph,
  #     'metadata'      => Array.new(num_metadata).map { Metadatum.generate_fake }
  #   }
  # end
  
  def initialize(opts={})
    @metadata = []
    opts.each do |name, value|
      send("#{name}=", value) if ATTRIBUTES.include?(name.to_sym)
    end
  end
  
  # Use the calais request UUID as the primary key for now.
  def id
    @calais_request_id
  end
  
  def save
    DC::Stores::EntryStore.new.save(self)
    DC::Stores::AssetStore.new.save_full_text(self)
    DC::Stores::MetadataStore.new.save_document(self)
  end
  
  def to_entry_hash
    ENTRY_ATTRIBUTES.inject({}) do |memo, name|
      memo[name.to_s] = send(name)
    end
  end
  
end