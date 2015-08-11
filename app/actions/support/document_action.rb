require 'fileutils'

class DocumentAction < CloudCrowd::Action
  # The default merge behavior just returns the document id.
  def merge
    document.update(:status => DC::Status::AVAILABLE) # ideally this would happen as the result of the callback
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
    document.update :access => DC::Access::ERROR, :status => DC::Status::ERROR
  end
  
  def fail_document_and_notify_on_exception
    begin
      yield
    rescue => error
      fail_document
      LifecycleMailer.exception_notification(error,options).deliver
      raise error
    end
  end

end
