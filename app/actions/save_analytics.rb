require File.dirname(__FILE__) + '/support/setup'

class SaveAnalytics < CloudCrowd::Action

  def process
    handle_errors do
      doc_ids = []
      input.each do |key, hits|
        id, url = *key.split(':', 2)
        id = id.to_i
        next unless url && (doc = Document.unrestricted.find_by_id(id))
        doc_ids << id
        RemoteUrl.record_hits(id, url, hits)
      end
      RemoteUrl.populate_detected(doc_ids)
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