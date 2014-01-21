require File.dirname(__FILE__) + '/support/setup'

class DuplicateDocuments < CloudCrowd::Action

  def process
    begin
      Document.where( {:id => input} ).find_each do |doc|
        doc.duplicate!(account, options)
      end
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e, options)
      raise e
    end
    true
  end

  private

  def account
    @account ||= Account.find(options['account_id']) if options['account_id']
  end

end
