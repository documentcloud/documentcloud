# Responsible for sending out lifecycle emails to active accounts.
class LifecycleMailer < ActionMailer::Base

  SUPPORT   = 'support@documentcloud.org'
  NO_REPLY  = 'no-reply@documentcloud.org'

  # Mail instructions for a new account, with a secure link to activate,
  # set their password, and log in.
  def login_instructions(account, admin=nil)
    subject     "Welcome to DocumentCloud"
    from        [SUPPORT, admin && admin.email].compact
    recipients  [account.email]
    body        :account            => account,
                :key                => account.security_key.key,
                :organization_name  => account.organization_name
  end

  # Mail instructions for a document review, with a secure link to the
  # document viewer, where the user can annotate the document.
  def reviewer_instructions(documents, inviter_account, reviewer_account=nil, message=nil)
    subject     "Review \"#{documents[0].title}\" on DocumentCloud" if documents.count == 1
    subject     "Review #{documents.count} documents on DocumentCloud" if documents.count > 1
    from        [SUPPORT, inviter_account.email].compact
    recipients  [reviewer_account.email] if reviewer_account
    body        :documents            => documents,
                :key                  => reviewer_account && reviewer_account.security_key.key,
                :organization_name    => documents[0].account.organization_name,
                :account_exists       => reviewer_account && !reviewer_account.reviewer?,
                :inviter_account      => inviter_account,
                :reviewer_account     => reviewer_account,
                :message              => message
  end

  # Mail instructions for resetting an active account's password.
  def reset_request(account)
    subject     "DocumentCloud password reset"
    from        SUPPORT
    recipients  [account.email]
    body        :account            => account,
                :key                => account.security_key.key
  end

  # When someone sends a message through the "Contact Us" form, deliver it to
  # us via email.
  def contact_us(account, params)
    name = account ? account.full_name : params[:email]
    subject     "DocumentCloud message from #{name}"
    from        NO_REPLY
    recipients  SUPPORT
    body        :account => account, :message => params[:message], :email => params[:email]
    @headers['Reply-to'] = account ? account.email : params[:email]
  end

  # Mail a notification of an exception that occurred in production.
  def exception_notification(error, params=nil)
    subject     "DocumentCloud exception (#{Rails.env}): #{error.class.name}"
    from        NO_REPLY
    recipients  [SUPPORT]
    body        :params => params, :error => error
  end

  # When a batch of uploaded documents has finished processing, email
  # the account to let them know.
  def documents_finished_processing(account, document_count)
    subject     "Your documents are ready"
    from        SUPPORT
    recipients  [account.email]
    body        :account  => account,
                :count    => document_count
  end
  
  # Accounts and Document CSVs mailed out every 1st and 15th of the month
  def account_and_document_csvs
    subject       "Accounts (CSVs)"
    from          NO_REPLY
    recipients    ['samuel@documentcloud.org']
    content_type  "multipart/alternative"
    
    part :content_type => "text/plain", 
         :body => render_message("account_and_document_csvs.text.plain", :date => Time.now)
    
    attachment "text/csv" do |a|  
      a.body     = DC::Statistics.accounts_csv
      a.filename = 'accounts.csv'
    end

    attachment "text/csv" do |a|
      a.body     = DC::Statistics.top_documents_csv
      a.filename = 'top_documents.csv'
    end
  end
  
  def logging_email(email_subject, args)
    subject       email_subject
    from          NO_REPLY
    recipients    [SUPPORT]
    body          :args => args,
                  :line => line
  end
end
