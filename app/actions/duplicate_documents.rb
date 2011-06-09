require File.dirname(__FILE__) + '/support/setup'

class DuplicateDocuments < CloudCrowd::Action

  def process
    documents = Document.find(:all, :conditions => {:id => input})
    puts "Input: #{input.inspect}"
    puts "Options: #{options.inspect}"
    puts "Document: #{documents.inspect}"
    puts "Account: #{account.inspect}"
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