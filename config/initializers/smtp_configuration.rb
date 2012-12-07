unless Rails.env.development?

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address        => SECRETS['smtp_host'],
    :port           => 25,
    :domain         => SECRETS['smtp_domain'],
    :user_name      => SECRETS['smtp_user'],
    :password       => SECRETS['smtp_password'],
    :authentication => :login
  }

end