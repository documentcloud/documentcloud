require File.dirname(__FILE__) + '/support/setup'
require 'fileutils'

class DocumentModBase < CloudCrowd::Action
  
  def merge
    document.update_attributes :access => access
    document.id
  end
  
  private
  
  def prepare_pdf
    @pdf = document.slug + '.pdf'
    File.open(@pdf, 'w+') {|f| f.write(asset_store.read_pdf(document)) }
  end
  
  def upload_text_assets(pages)
    asset_store.save_full_text(document, access)
    pages.each do |page|
      asset_store.save_page_text(document, page.page_number, page.text, access)
    end
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