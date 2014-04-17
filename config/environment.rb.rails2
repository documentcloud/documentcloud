# Be sure to restart your server when you modify this file
require 'erb'

# Since both Ruby2 and RubyGems 2 remove source_index
# hack them back in.
unless Gem.methods.include?("source_index")
  module Gem
    def self.source_index
      sources
    end

    def self.cache
      sources
    end

    SourceIndex = Specification

    class SourceList
      # If you want vendor gems, this is where to start writing code.
      def search( *args ); []; end
      def each( &block ); end
      include Enumerable
    end
  end
end

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.18' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# DocumentCloud-specific configuration.
SECRETS   = YAML.load_file("#{Rails.root}/secrets/secrets.yml")[RAILS_ENV]
DC_CONFIG = YAML.load( ERB.new(File.read( Rails.root.join('config','document_cloud.yml') ) ).result )[RAILS_ENV]

# Settings in config/initializers take precedence over this.
Rails::Initializer.run do |config|

  # Standard Library:
  require 'digest/md5'
  require 'tmpdir'
  require 'fileutils'
  require 'iconv'
  require 'forwardable'

  # Middleware
  paths = config.respond_to?(:autoload_paths) ? config.autoload_paths : config.load_paths
  paths << "#{Rails.root}/app/middleware"

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

# Tell RightAWS to always reset the connection after failure.
RightAws::AWSErrorHandler.close_on_4xx_probability = 100

RightAws::RightAWSParser.xml_lib = 'libxml'
ActiveRecord::Base.include_root_in_json = false
ActiveSupport::JSON.backend = 'JSONGem'
require 'json'
