# NB: Doesn't inherit from ActiveRecord::Base ... yet.
class Document
  include ActionView::Helpers::TextHelper
  
  ENTRY_ATTRIBUTES = [:author, :created_at, :date, :id, :language, :organization, 
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
    opts.each do |name, value|
      send("#{name}=", value) if ATTRIBUTES.include?(name.to_sym)
    end
  end
  
  # The document id should be some way of uniquely identifying the document.
  # Disallow leading zeros so we can safely convert it to an integer.
  # TODO: Add created_at, or some other discriminator between textually-
  # identical documents, to this.
  def id
    return @id if @id
    new_id = Digest::SHA1.hexdigest(full_text)[0...15]
    new_id[0] = '1' if new_id.first == '0'
    @id = new_id
  end
  
  # FIXME: Get an integer representation of the UUID (we need it to be an integer
  # for Dystopia to store). Can't convert the entire UUID because it's too large.
  # Needs a better solution.
  def integer_id
    id.hex
  end
  
  # Two documents are equal if they have the same document id. If we have two
  # different objects for the same document floating around in a thread...
  # that's a bug.
  def ==(other)
    id == other.id && other.is_a?(Document)
  end
  
  # TODO: Saving the full text both as an asset and in the full text index
  # may be redundant.
  def save
    DC::Store::EntryStore.new.save(self)
    DC::Store::AssetStore.new.save_full_text(self)
    DC::Store::MetadataStore.new.save_document(self)
    DC::Store::FullTextStore.new.save(self)
  end
  
  def to_entry_hash
    ENTRY_ATTRIBUTES.inject({}) do |memo, name|
      memo[name.to_s] = send(name)
      memo
    end
  end
  
  def to_json
    to_entry_hash
  end
  
  # TODO: Think about keeping a metadata_count in the document entry, and then
  # we can determine if we've already got the complete set of data, or need to
  # go query the store for more.
  def metadata
    @metadata ||= DC::Store::MetadataStore.new.find_by_document(self)
  end
  
  # Categories are stored alongside the rest of the metadata for the moment,
  # so pulling them out means going fishing.
  def categories
    @categories ||= metadata.select {|meta| meta.type == 'category' }
  end
  
  def full_text
    return nil unless @full_text || @id
    @full_text ||= DC::Store::AssetStore.new.find_full_text(self)
  end
  
  def inspect
    short_title = ActionView::Helpers::TextHelper
    "#<Document \"#{truncate(title, 50)}\">"
  end
  
end