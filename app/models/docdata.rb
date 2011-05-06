class Docdata < ActiveRecord::Base
  
  belongs_to :document
  validates_uniqueness_of :document_id, :allow_nil => true
  
  after_save :index_document
  
  def self.to_hstore(hash)
    hash.map {|k, v| "\"#{sanitize(k)}\"=>\"#{sanitize(v)}\"" }.join(',')
  end
  
  def self.sanitize(obj)
    obj.to_s.gsub(/[\\"]/, '')
  end
  
  def data=(hash)
    @data = nil
    if hash.empty?
      self[:data] = nil
      self.destroy
    else
      self[:data] = Docdata.to_hstore(hash)
    end
  end
  
  def data    
    @data ||= Hash[(self[:data] || "").scan(/"(.*?[^\\]|)"=>"(.*?[^\\]|)"/)]
  end
  
  def index_document
    self.document.index
  end
  
end