class LifecycleMailer < ActionMailer::Base
  
  def login_instructions(account)
    subject     "DocumentCloud Account"
    from        "noreply@documentcloud.org"
    recipients  [account.email]
    body        :account            => account, 
                :key                => account.security_key.key,
                :organization_name  => account.organization.name
  end

end
