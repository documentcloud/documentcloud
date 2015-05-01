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
    # email manifest to us.
    successes = []
    failures = []
    input.each do |result| 
      successes.push(result["succeeded"])
      failures.push(result["failed"])
    end
    LifecycleMailer.logging_email("DuplicateDocument batch manifest", {:successes => successes, :failures => failures})
  end
  
  private

  def account
    @account ||= Account.find(options['account_id']) if options['account_id']
  end
end
