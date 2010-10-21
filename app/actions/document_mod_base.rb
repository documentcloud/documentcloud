require File.dirname(__FILE__) + '/support/setup'
require 'fileutils'

class DocumentModBase < CloudCrowd::Action
  
  def merge
    document.id
  end
  
  private
  
  def prepare_pdf
    @pdf = document.slug + '.pdf'
    File.open(@pdf, 'w+') {|f| f.write(asset_store.read_pdf(document)) }
  end
  
  def document
    return @document if @document
    ActiveRecord::Base.establish_connection
    @document = Document.find(options['id'])
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end
  
  def access
    options['access'] || DC::Access::PRIVATE
  end
  
end