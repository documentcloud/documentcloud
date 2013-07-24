require 'dc/access'
require 'dc/roles'
require 'dc/sanitized'
require 'dc/validators'
require 'dc/language'
require 'dc/hstore'
require 'dc/store/asset_store'
require 'dc/search'
require 'dc/statistics'

Dir[File.dirname(__FILE__) + '/dc/import/*.rb'].each {|file| require file }


module DC

  # The canonical server root, including SSL, if requested.
  def self.server_root(options={:ssl => true, :agnostic => false, })
    root = 'http://'
    root = 'https://' if options[:force_ssl] || (options[:ssl] && Thread.current[:ssl])
    root = '//' if options[:agnostic]
    root + DC::CONFIG['server_root']
  end

end
