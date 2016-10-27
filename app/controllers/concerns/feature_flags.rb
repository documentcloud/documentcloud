module FeatureFlags

  # Feature helpers to enable features based on the account/user
  def can_authencitate_with_documentcloud_accounts?
    staff? || beta_tester?
  end

  def staff?
    email =~ /@.*\bdocumentcloud\.org/ ? true : false
  end

  def beta_tester?
    DC::SECRETS['beta_testers'].includes?(email)
  end
end
