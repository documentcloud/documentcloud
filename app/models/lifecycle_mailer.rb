class LifecycleMailer < ActionMailer::Base

  def support_email
    env = Rails.env.production? ? '' : " (#{RAILS_ENV})"
    "\"DocumentCloud#{env}\" <support@documentcloud.org>"
  end

  def login_instructions(account)
    subject     "DocumentCloud Account"
    from        support_email
    recipients  [account.rfc_email]
    body        :account            => account,
                :key                => account.security_key.key,
                :organization_name  => account.organization_name
  end

end
