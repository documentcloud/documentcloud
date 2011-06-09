require File.dirname(__FILE__) + '/support/setup'

class DuplicateDocuments < CloudCrowd::Action

  def process
    documents = Document.find(:all, :conditions => {:id => input})
    documents.each do |doc|
      doc.duplicate!(account, options)
    end
    true
  end


  private

  def account
    @account ||= Account.find(options['account_id']) if options['account_id']
  end

end