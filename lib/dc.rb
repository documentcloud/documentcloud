module DC

  # The canonical server root, including SSL, if requested.
  def self.server_root(options={:ssl => true})
    root = options[:ssl] && Thread.current[:ssl] ? 'https://' : 'http://'
    root + DC_CONFIG['server_root']
  end

end