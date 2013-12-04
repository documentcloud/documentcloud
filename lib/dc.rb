require 'dc/access'
require 'dc/roles'
require 'dc/sanitized'
require 'dc/validators'
require 'dc/language'
require 'dc/hstore'
require 'dc/store/asset_store'
require 'dc/search'
require 'dc/statistics'
require 'dc/zip_utils'
require 'dc/import'
require 'dc/i18n'
module DC

  # The canonical server root, including SSL, if requested.
  def self.server_root(options={:ssl => true, :agnostic => false, })
    root = case
           when options[:force_ssl] || (options[:ssl] && Thread.current[:ssl]) then 'https://'
           when options[:agnostic] then '//'
           else
             'http://'
           end
    root + DC::CONFIG['server_root']
  end

end
