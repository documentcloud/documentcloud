require File.dirname(__FILE__) + '/support/setup'

class DuplicateDocuments < DocumentAction

  def process
    fail_document_and_notify_on_exception do
      Document.where( {:id => input} ).find_each do |doc|
        doc.duplicate!(account, options)
      end
    end
    true
  end

  private

  def account
    @account ||= Account.find(options['account_id']) if options['account_id']
  end

end
