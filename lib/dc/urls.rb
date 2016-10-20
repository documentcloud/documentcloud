module DC

  # The canonical server root, including SSL, if requested.
  def self.server_root(options={:ssl => true, :agnostic => false })
    url_for('server_root', options)
  end

  def self.asset_root(options={:ssl => true, :agnostic => false })
    url_for('asset_root', options)
  end

  # Temporary until we have a single development pipeline for all our assets. 
  # Currently, some are served from the platform during development 
  # (dev.dcloud.org) and some from the Broccoli-based `workspace` repo 
  # (assets.dcloud.org), necessitating two different roots. In 
  # staging/production, this distinction doesn't exist. This method can go away 
  # once `workspace` owns all assets in development.
  def self.workspace_asset_root(options={:ssl => true, :agnostic => false })
    url_for('workspace_asset_root', options)
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
