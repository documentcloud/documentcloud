# Responsible for sending out lifecycle emails to active accounts.
class LifecycleMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper # pluralize and friends

  SUPPORT    = 'support@documentcloud.org'
  EXCEPTIONS = 'exceptions@documentcloud.org'
  NO_REPLY   = 'no-reply@documentcloud.org'
  INFO       = 'info@documentcloud.org'
  default from: SUPPORT

  # Mail instructions for a new account, with a secure link to activate,
  # set their password, and log in.
  def login_instructions(account, organization, admin=nil)
    @admin   = admin
    @account = account
    @organization = organization
    options = {
      :subject       => DC.t(account, 'welcome_to_document_cloud'),
      :to            => @account.email,
      :content_type  => "text/plain",
      :template_path => translation_path_for( account.language )
    }
    account.ensure_security_key!
    options[ :cc  ] = @admin.email if @admin
    mail( options )
  end

  def membership_notification(account, organization, admin=nil)
    @admin   = admin
    @account = account
    @organization_name = organization.name
    mail(
      :subject       => DC.t(account, 'youve_been_added_to_x', organization.name ),
      :to            => account.email,
      :content_type  => "text/plain",
      :template_path => translation_path_for( account.language )
    )
  end

  # Mail instructions for a document review, with a secure link to the
  # document viewer, where the user can annotate the document.
  def reviewer_instructions(documents, inviter_account, reviewer_account=nil, message=nil, key='')
    @documents            = documents
    @key                  = key
    @organization_name    = documents[0].account.organization_name
    @account_exists       = reviewer_account && !reviewer_account.reviewer?
    @inviter_account      = inviter_account
    @reviewer_account     = reviewer_account
    @message              = message
    options = {
      :cc            => inviter_account.email,
      :subject       => DC.t(inviter_account,'review_x_documents', documents.count, documents.first.title ),
      :content_type  => "text/plain",
      :template_path => translation_path_for( inviter_account.language )
    }
    options[:to] = reviewer_account.email if reviewer_account
    mail( options )
  end

  # Mail instructions for resetting an active account's password.
  def reset_request(account)
    @account = account
    account.ensure_security_key!
    @key     = account.security_key.key
    mail({
        :to => account.email, :subject => DC.t(account,'password_reset'),
        :content_type  => "text/plain",
        :template_path => translation_path_for( account.language )
    })
  end

  # When someone sends a message through the "Contact Us" form, deliver it to
  # us via email.
  def contact_us(account, params)
    name = account ? account.full_name : params[:email]
    @account = account
    @message = params[:message]
    @email   = params[:email]
    mail({
        :subject  => "DocumentCloud message from #{name}",
        :from     => NO_REPLY,
        :reply_to => account ? account.email : params[:email],
        :to       => SUPPORT
      })
  end

  # Mail a notification of an exception that occurred in production.
  def exception_notification(error, params=nil)
    params.delete(:password) if params
    @params = params
    @error  = error
    mail({
        :subject  => "DocumentCloud exception (#{Rails.env}:#{`hostname`.chomp}): #{error.class.name}",
        :from     => NO_REPLY,
        :to       => EXCEPTIONS
      })
  end

  # When a batch of uploaded documents has finished processing, email
  # the account to let them know.
  def documents_finished_processing(account, document_count)
    @account  = account
    @count    = document_count
    mail({
        :to => account.email, :subject => DC.t(account,'documents_are_ready'),
        :content_type  => "text/plain",
        :template_path => translation_path_for( account.language )
      })
  end

  # Accounts and Document CSVs mailed out every 1st and 15th of the month
  def account_and_document_csvs
    date = Date.today.strftime "%Y-%m-%d"

    accounts = ""
    DC::Statistics.accounts_csv( CSV.new(accounts) )
    attachments["accounts-#{date}.csv"] = {
      mime_type: 'text/csv',
      content: accounts
    }

    attachments["top-documents-#{date}.csv"] = {
      mime_type: 'text/csv',
      content: DC::Statistics.top_documents_csv
    }
    mail({
           :subject => "Accounts (CSVs)",
           :from    => NO_REPLY,
           :to      => INFO
         })
  end

  def logging_email( email_subject, args )
    @args = args
    stack=caller(0)
    # search through the stack for the call right before
    # it hit the mailer's method_missing and include everything before
    # it in the email.
    key_frame = stack.index{ |l| l=~/method_missing\'$/ } || 0
    @stack = stack[ key_frame+1..-1 ]
    mail({
        :subject  => email_subject,
        :from     => NO_REPLY,
        :to       => SUPPORT
         })
  end


  # Email the owner of a document which is having difficulty processing
  def permission_to_review(document)
    @document = document
    mail(
      :subject       => "We were unable to successfully process a document",
      :cc            => SUPPORT,
      :to            => document.account.email,
      :content_type  => "text/plain"
    )
  end


  private

  # this will break if HTML format emails are ever used.
  # If we do, this will have to check text.html.erb extension as well
  def translation_path_for( language )
    view = action_name
    path = Rails.root.join('app','views', 'lifecycle_mailer', language, "#{view}.text.erb" )
    "lifecycle_mailer/" + ( path.exist? ? language : DC::Language::DEFAULT )
  end


end
