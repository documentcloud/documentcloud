require File.dirname(__FILE__) + '/support/setup'

class UpdateAccess < CloudCrowd::Action

  def process
    begin
      ActiveRecord::Base.establish_connection
      document = Document.find(input)
      DC::Store::AssetStore.new.set_access(document, document.access)
      document.update_attributes(:access => options['access'])
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      document.update_attributes(:access => DC::Access::ERROR) if document
      raise e
    end
    true
  end

end