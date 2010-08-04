# Inherit Rails environment from Sinatra.
RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RAILS_ENV'] = ENV['RACK_ENV']

# Load the DocumentCloud environment if we're in a Node context.
if CloudCrowd.node?
  require 'logger'
  log = Logger.new(STDOUT)
  log.level = Logger::WARN if RAILS_ENV == 'production'
  Object.const_set "RAILS_DEFAULT_LOGGER", log
  require 'rubygems'
  gem 'rails', '~> 2.0'
  require 'active_record'
  require 'config/environment'
end
