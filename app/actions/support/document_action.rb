require 'fileutils'

class DocumentAction < CloudCrowd::Action

  # The default merge behavior just returns the document id.
  def merge
    document.id
  end

  protected

  # Generate the file name we're going to use for the PDF, and save it locally.
  def prepare_pdf
    @pdf = document.slug + '.pdf'
    File.open(@pdf, 'wb') {|f| f.write(asset_store.read_pdf(document)) }
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

  def fail_document
    document.update_attributes :access => DC::Access::ERROR
  end

end
