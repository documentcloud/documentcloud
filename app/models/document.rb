class Document
  include ActionView::Helpers::TextHelper
  
  ENTRY_ATTRIBUTES = [:author, :created_at, :date, :id, :language, :source, 
                      :summary, :title, :calais_request_id, :thumbnail_path,
                      :small_thumbnail_path, :pdf_path, :organization_id,
                      :account_id, :access]
                      
  TEMPORARY_ATTRIBUTES = [:full_text, :rdf, :metadata, :calais_signature]
  
  SEARCHABLE_ATTRIBUTES = [:title, :source]
  
  INTEGER_ATTRIBUTES = [:organization_id, :account_id, :access]
  
  ATTRIBUTES = ENTRY_ATTRIBUTES + TEMPORARY_ATTRIBUTES
                      
  ATTRIBUTES.each {|a| attr_accessor a }
  
  INTEGER_ATTRIBUTES.each {|a| class_eval("def #{a}=(val); @#{a} = val.to_i; end") }
  
  def initialize(opts={})
    set_attributes(opts)
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
  # for Sphinx to store). Can't convert the entire UUID because it's too large.
  # Needs a better solution.  
  def integer_id
    @integer_id ||= id.hex
  end
  
  # A document's metadata are keyed by organization_id/account_id/document_id
  def metadata_prefix
    raise "incompletely loaded document" unless organization_id && account_id && id
    "#{organization_id}/#{account_id}/#{id}"
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
    DC::Store::AssetStore.new.save_document(self)
    DC::Store::EntryStore.new.save(self)
    DC::Store::MetadataStore.new.save_document(self)
  end
  
  # Remove all the pieces of the document that we've saved.
  def destroy
    DC::Store::AssetStore.new.destroy_document(self)
    DC::Store::EntryStore.new.destroy(self)
    DC::Store::MetadataStore.new.destroy_document(self)
    DC::Store::FullTextStore.new.destroy(self)
  end
  
  def to_entry_hash
    ENTRY_ATTRIBUTES.inject({}) do |memo, name|
      memo[name.to_s] = send(name)
      memo
    end
  end
  
  def as_json(opts={})
    to_entry_hash
  end
  
  def set_attributes(attrs={})
    attrs.each do |name, value|
      send("#{name}=", value) if ATTRIBUTES.include?(name.to_sym)
    end
    @id = attrs[:pk] if attrs[:pk]
  end
  
  # TODO: Think about keeping a metadata_count in the document entry, and then
  # we can determine if we've already got the complete set of data, or need to
  # go query the store for more.
  def metadata
    @metadata ||= DC::Store::MetadataStore.new.find_by_documents([self])
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
    identifier = @title ? "\"#{truncate(@title, 50)}\"" : "##{@id}"
    "#<Document #{identifier}>"
  end
  
end