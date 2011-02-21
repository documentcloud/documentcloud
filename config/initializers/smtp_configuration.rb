unless Rails.env.development?

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address        => 'mail.documentcloud.org',
    :port           => 25,
    :user_name      => 'smtp@documentcloud.org',
    :password       => SECRETS['smtp_password'],
    :authentication => :plain
  }

end