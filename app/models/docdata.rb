class Docdata < ActiveRecord::Base
  
  belongs_to :document
  validates_uniqueness_of :document_id, :allow_nil => true
  
  after_save :index_document
  
  def self.to_hstore(hash)
    hash.map {|k, v| "\"#{PGconn.escape(k.to_s)}\"=>\"#{PGconn.escape(v.to_s)}\"" }.join(',')
  end
  
  def data=(obj)
    @data = nil
    return self[:data] = obj if obj.is_a? String
    return unless validate_keys(obj)
    if obj.empty?
      self[:data] = nil
      self.destroy
    else
      self[:data] = Docdata.to_hstore(obj)
    end
  end
  
  def data    
    @data ||= Hash[(self[:data] || "").scan(/"(.*?[^\\]|)"=>"(.*?[^\\]|)"/)]
  end
  
  def validate_keys(hash)
    if forbidden = hash.keys.detect {|key| DC::ALL_SEARCHES.include?(key.to_sym) }
      errors.add_to_base "Invalid data key: #{forbidden}"
      false
    else
      true
    end
  end
  
  def index_document
    self.document.index
  end
  
end