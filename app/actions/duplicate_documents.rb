require File.dirname(__FILE__) + '/support/setup'

class DuplicateDocuments < CloudCrowd::Action

  def process
      Document.where( {:id => input} ).find_each do |doc|
        begin
          doc.duplicate!(account, options)
        rescue => e
          LifecycleMailer.exception_notification(e, options.merge({:document_id=>doc.id}) ).deliver
          raise e
        end
      end
      true
  end

  private

  def account
    @account ||= Account.find(options['account_id']) if options['account_id']
  end

end
