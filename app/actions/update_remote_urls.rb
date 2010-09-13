require File.dirname(__FILE__) + '/support/setup'

class UpdateRemoteUrls < CloudCrowd::Action

  def process
    handle_errors do
      RemoteUrl.set_all_detected_remote_urls!
    end
  end


  private

  def handle_errors
    begin
      yield
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    true
  end

end