# Responsible for sending out lifecycle emails to active accounts.
class LifecycleMailer < ActionMailer::Base

  # Mail instructions for a new account, with a secure link to activate,
  # set their password, and log in.
  def login_instructions(account)
    subject     "DocumentCloud Account"
    from        support_email
    recipients  [account.rfc_email]
    body        :account            => account,
                :key                => account.security_key.key,
                :organization_name  => account.organization_name
  end


  private

  def support_email
    env = Rails.env.production? ? '' : " (#{RAILS_ENV})"
    "\"DocumentCloud#{env}\" <support@documentcloud.org>"
  end

end
