require File.dirname(__FILE__) + '/support/setup'

class UpdateAccess < CloudCrowd::Action

  def process
    begin
      ActiveRecord::Base.establish_connection
      document = Document.find(input)
      DC::Store::AssetStore.new.set_access(document, document.access)
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    true
  end

end