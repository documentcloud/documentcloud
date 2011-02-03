module DC

  # The canonical server root, including SSL, if requested.
  def self.server_root(options={:ssl => true})
    root = 'http://'
    root = 'https://' if options[:force_ssl] || (options[:ssl] && Thread.current[:ssl])
    root + DC_CONFIG['server_root']
  end

end