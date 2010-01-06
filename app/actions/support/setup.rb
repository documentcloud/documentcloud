# Inherit Rails environment from Sinatra.
RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RAILS_ENV'] = ENV['RACK_ENV']

# Load the DocumentCloud environment if we're in a Node context.
if CloudCrowd.node?
  require 'logger'
  Object.const_set "RAILS_DEFAULT_LOGGER", Logger.new(STDOUT)
  require 'rubygems'
  require 'active_record'
  require 'config/environment'
end