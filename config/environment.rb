# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Settings in config/initializers take precedence over this.
Rails::Initializer.run do |config|

  # Standard Library:
  require 'digest/md5'
  require 'tmpdir'
  require 'fileutils'

  # Gems:
  config.gem 'json',                  :version => '>= 1.1.9'

  config.gem 'calais',                :version => '>= 0.0.8'
  config.gem 'rest-client',           :version => '>= 1.0.3',       :lib => 'rest_client'
  config.gem 'bcrypt-ruby',           :version => '>= 2.1.2',       :lib => 'bcrypt'
  config.gem 'rubyzip',               :version => '>= 0.9.1',       :lib => 'zip/zip'
  config.gem 'right_aws',             :version => '>= 1.10.0'
  config.gem 'postgres',              :version => '>= 0.7.9.2008.01.28'
  config.gem 'jammit',                :version => '>= 0.4.0'
  config.gem 'docsplit',              :version => '>= 0.1.0'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  config.frameworks -= [:active_resource]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

RightAws::RightAWSParser.xml_lib = 'libxml'
ActiveRecord::Base.include_root_in_json = false
ActiveSupport::JSON.backend = 'JSONGem'
require 'json'
require 'json/add/rails'
