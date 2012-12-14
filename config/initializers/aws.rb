# More generous HTTP timeouts ... mostly because Solr is unresponsive.

Rightscale::HttpConnection.params[:http_connection_open_timeout] = 30
Rightscale::HttpConnection.params[:http_connection_read_timeout] = 300


