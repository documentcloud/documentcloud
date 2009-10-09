# A metadatum, for our purposes, is a piece of metadata either about or 
# contained by a document (i.e., it may have a location within the document's
# text.) Metadata have a whitelisted type, or list of acceptable types.
class Metadatum
  
  attr_accessor :type, :occurrences, :relevance, :value, :calais_hash, 
                :document_id, :organization_id, :account_id, :access, :id
  
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
      {
        :id => data['id'] || data[:pk],
        :access => data['access'],
        :occurrences => Occurrence.from_csv(data['occurrences']),
        :calais_hash => data['calais_hash']
      }
    )
  end
  
  def initialize(value, type, relevance, opts={})
    @value, @type, @relevance = value, type, relevance
    @occurrences = opts[:occurrences] || []
    @calais_hash = opts[:calais_hash]
    @access      = opts[:access] || opts[:document].access
    set_scope(opts[:id], opts[:document])
  end
  
  def set_scope(an_id=nil, document=nil)
    if an_id
      @id = an_id
      @organization_id, @account_id, @document_id = *@id.split('/')
      @organization_id = @organization_id.to_i
      @account_id = @account_id.to_i
    elsif document
      @id = "#{document.metadata_prefix}/#{@calais_hash || @value}"
    else
      raise "Tried to instantiate a Metadatum without an id or document"
    end
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
      'id'          => @id,
      'value'       => @value,
      'type'        => @type,
      'relevance'   => @relevance,
      'access'      => @access,
      'occurrences' => Occurrence.to_csv(@occurrences),
      'calais_hash' => @calais_hash
    }
  end
  
end