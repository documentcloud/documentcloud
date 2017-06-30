require File.dirname(__FILE__) + '/support/setup'

class ReindexEverything < CloudCrowd::Action
  
  def process
    outcomes = {:succeeded=>[], :failed => []}
    docs = Document.where({:id => input}).includes(:pages, :docdata)
    ids = []
    docs.find_each do |document|
      counter = 0
      begin
        Sunspot.index(document)
        document.pages.each{ |page| Sunspot.index(page) }
        ids << document.id
      rescue Exception => e
        counter += 1
        (sleep(0.25 * counter) and retry) if counter < 5
        LifecycleMailer.exception_notification(e,options).deliver_now
        outcomes[:failed].push(:id=>doc.id)
      end
    end
    Sunspot.commit
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
    
    duplicate_projects(successes) if options['projects']
    
    data = {:successes => successes, :failures => failures}
    LifecycleMailer.logging_email("Reindexing batch manifest", data).deliver_now
    true
  end

end

=begin

ids = Document.pluck(:id); ids.size
blocks = ids.each_slice(100).to_a; blocks.size
blocks.each_slice(10){ |block| RestClient.post ProcessingJob.endpoint, { job: { action: "reindex_everything", inputs: block  }.to_json } }; ""

=end