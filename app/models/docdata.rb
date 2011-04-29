class Docdata < ActiveRecord::Base
  
  belongs_to :document
  
  after_save :index_document
  
  def data=(hash)
    self[:data] = hash.map {|k, v| "\"#{sanitize(k)}\"=>\"#{sanitize(v)}\"" }.join(',')
  end
  
  def data    
    @data ||= Hash[self[:data].scan(/"(.*?[^\\]|)"=>"(.*?[^\\]|)"/)]
  end
  
  def index_document
    self.document.index
  end
  
  
  private
  
  def sanitize(obj)
    obj.to_s.gsub(/[\\"]/, '')
  end
  
end