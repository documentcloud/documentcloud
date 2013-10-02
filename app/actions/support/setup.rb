# Inherit Rails environment from Sinatra.
RAILS_ROOT = File.expand_path("../../../../", __FILE__)
RAILS_ENV = ENV['RAILS_ENV'] = ENV['RACK_ENV']

# Load the DocumentCloud environment if we're in a Node context.
if CloudCrowd.node?
  $LOAD_PATH.unshift( RAILS_ROOT ) unless $LOAD_PATH.include?( RAILS_ROOT )
  require 'logger'
  log = Logger.new(STDOUT)
  log.level = Logger::WARN if RAILS_ENV == 'production'
  require 'rubygems'
  gem 'rails'
  require 'rails'
  Rails.logger = log
  require 'active_record'
  require 'config/environment'
end
