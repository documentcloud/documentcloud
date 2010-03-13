# Responsible for sending out lifecycle emails to active accounts.
class LifecycleMailer < ActionMailer::Base

  # Mail instructions for a new account, with a secure link to activate,
  # set their password, and log in.
  def login_instructions(account)
    subject     "Welcome to DocumentCloud"
    from        support_email
    recipients  [account.rfc_email]
    body        :account            => account,
                :key                => account.security_key.key,
                :organization_name  => account.organization_name
  end

  # Mail instructions for resetting an active account's password.
  def reset_request(account)
    subject     "DocumentCloud Password Reset"
    from        support_email
    recipients  [account.rfc_email]
    body        :account            => account,
                :key                => account.security_key.key
  end

  # Mail a notification of an exception that occurred in production.
  def exception_notification(error)
    subject     "DocumentCloud Exception: #{error.class.name}"
    from        support_email
    recipients  "jashkenas@gmail.com"
    body        :error => error
  end


  private

  def support_email
    Rails.env.production? ?
      'support@documentcloud.org' :
      "\"DocumentCloud (#{RAILS_ENV})\" <support@documentcloud.org>"
  end

end
