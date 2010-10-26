require File.dirname(__FILE__) + '/setup'
require 'fileutils'

class DocumentModBase < CloudCrowd::Action

  # The default merge behavior just returns the document id.
  def merge
    document.id
  end

  protected

  # Generate the file name we're going to use for the PDF, and save it locally.
  def prepare_pdf
    @pdf = document.slug + '.pdf'
    File.open(@pdf, 'w+') {|f| f.write(asset_store.read_pdf(document)) }
  end

  def document
    @document ||= Document.find(options['id'])
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

  def access
    options['access'] || DC::Access::PRIVATE
  end

  def reindex_all!
    document.full_text.refresh
    Page.refresh_page_map(document)
    EntityDate.refresh(document)
    document.update_attributes :access => access
    pages = document.reload.pages
    Sunspot.index pages
    document.reprocess_entities
    document.upload_text_assets(pages)
  end

end