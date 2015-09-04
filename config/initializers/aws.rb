AWS.config(
  :access_key_id     => DC::SECRETS['aws_access_key'],
  :secret_access_key => DC::SECRETS['aws_secret_key'],
  :logger            => Rails.logger,
  :http_idle_timeout => 60,
  :http_open_timeout => 30,
  :http_read_timeout => 300,
  :region            => DC::CONFIG['aws_region']
)
