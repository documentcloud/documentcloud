require File.dirname(__FILE__) + '/support/setup'

class DuplicateDocuments < CloudCrowd::Action

  def process
    outcomes = {:succeeded=>[], :failed => []}
    Document.where( {:id => input} ).find_each do |doc|
      begin
        doc.duplicate!(account, options)
      rescue => e
        LifecycleMailer.exception_notification(e, options.merge({:document_id=>doc.id}) ).deliver
        outcomes[:failed].push(:id=>doc.id, :access=>doc.access, :error=>{:name=>e.class.name, :message=>e.message})
      end
      outcomes[:succeeded].push(doc.id)
    end
    outcomes
  end
  
  def merge
    # Upon completion email us a manifest of success/failure
    successes = []
    failures = []
    input.each do |result| 
      successes += result["succeeded"]
      failures  += result["failed"]
    end
    data = {:successes => successes, :failures => failures}
    LifecycleMailer.logging_email("DuplicateDocument batch manifest", data).deliver
    true
  end
  
  private

  def account
    @account ||= Account.find(options['account_id']) if options['account_id']
  end
end
