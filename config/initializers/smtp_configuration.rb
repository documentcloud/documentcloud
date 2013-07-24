unless Rails.env.development?

  ActionMailer::Base.smtp_settings = {
    :address              => DC::SECRETS['smtp_host'],
    :port                 => 25,
    :domain               => DC::SECRETS['smtp_domain'],
    :user_name            => DC::SECRETS['smtp_user'],
    :password             => DC::SECRETS['smtp_password'],
    :authentication       => :login,
    :enable_starttls_auto => true
  }

end
