require File.dirname(__FILE__) + '/support/setup'

class ReindexEverything < CloudCrowd::Action
  
  def process
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
        LifecycleMailer.exception_notification(e,options).deliver
        retry if counter < 5
      end
    end
    ids
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
