module DC

  # The canonical server root, including SSL, if requested.
  def self.server_root(options={:ssl => true, :agnostic => false })
    url_for('server_root', options)
  end

  def self.cdn_root(options={:ssl => true, :agnostic => false })
    url_for('asset_root', options)
  end

  # Lookup the appropriate host from config/document_cloud.yml
  def self.url_for(config, options)
    root = case
           when options[:force_ssl] || (options[:ssl] && Thread.current[:ssl]) then 'https://'
           when options[:agnostic] then '//'
           else
             'http://'
           end
    root + DC::CONFIG[config]
  end

end
