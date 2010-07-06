# Responsible for sending out lifecycle emails to active accounts.
class LifecycleMailer < ActionMailer::Base

  SUPPORT   = 'support@documentcloud.org'
  NO_REPLY  = 'no-reply@documentcloud.org'

  # Mail instructions for a new account, with a secure link to activate,
  # set their password, and log in.
  def login_instructions(account)
    subject     "Welcome to DocumentCloud"
    from        SUPPORT
    recipients  [account.rfc_email]
    body        :account            => account,
                :key                => account.security_key.key,
                :organization_name  => account.organization_name
  end

  # Mail instructions for resetting an active account's password.
  def reset_request(account)
    subject     "DocumentCloud Password Reset"
    from        SUPPORT
    recipients  [account.rfc_email]
    body        :account            => account,
                :key                => account.security_key.key
  end

  # Mail a notification that a new account has been enabled in your organization.
  def enabled_notification(account, emails)
    subject     "DocumentCloud Account Enabled: #{account.full_name}"
    from        SUPPORT
    recipients  emails
    body        :account => account
  end

  # When someone sends a message through the "Contact Us" form, deliver it to
  # us via email.
  def contact_us(account, message)
    subject     "DocumentCloud Message from #{account.full_name}"
    from        NO_REPLY
    recipients  SUPPORT
    body        :account => account, :message => message
    @headers['Reply-to'] = account.email
  end

  # Mail a notification of an exception that occurred in production.
  def exception_notification(error)
    subject     "DocumentCloud Exception: #{error.class.name}"
    from        NO_REPLY
    recipients  "jashkenas@gmail.com"
    body        :error => error
  end

end
