require File.dirname(__FILE__) + '/support/setup'

class ReindexEverything < CloudCrowd::Action
  
  def process
    docs = Document.all(:conditions=>{:id => input}, :include => [:pages, :docdata])
    docs.each do |document|
      counter = 0
      begin
        Sunspot.index(document)
        document.pages.each{ |page| Sunspot.index(page) }
      rescue Exception => e
        counter += 1
        LifecycleMailer.deliver_exception_notification(e, options)
        retry if counter < 5
      end
    end
    docs.map(&:id)
  end

  def merge
    counter = 0
    begin
      Sunspot.commit
    rescue Exception => e
      counter += 1
      LifecycleMailer.deliver_exception_notification(e, options)
      retry if counter < 5
    end
  end
end
