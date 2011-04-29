class Docdata < ActiveRecord::Base
  
  belongs_to :document
  
  after_save :index_document
  
  def self.to_hstore(hash)
    hash.map {|k, v| "\"#{sanitize(k)}\"=>\"#{sanitize(v)}\"" }.join(',')
  end
  
  def self.sanitize(obj)
    obj.to_s.gsub(/[\\"]/, '')
  end
  
  def data=(hash)
    self[:data] = Docdata.to_hstore(hash)
  end
  
  def data    
    @data ||= Hash[self[:data].scan(/"(.*?[^\\]|)"=>"(.*?[^\\]|)"/)]
  end
  
  def index_document
    self.document.index
  end
  
end