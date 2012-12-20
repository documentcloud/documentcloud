# More generous HTTP timeouts ... mostly because Solr is unresponsive.

Rightscale::HttpConnection.params[:http_connection_open_timeout] = 30
Rightscale::HttpConnection.params[:http_connection_read_timeout] = 300

AWS.config(
  :access_key_id     => SECRETS['aws_access_key'], 
  :secret_access_key => SECRETS['aws_secret_key'],
  :logger            => Rails.logger,
  :http_idle_timeout => 60,
  :http_open_timeout => 30,
  :http_read_timeout => 300
)
