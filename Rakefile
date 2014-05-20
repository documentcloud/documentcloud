# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

if ['test','development','staging','production'].include?(ARGV.first)
    RAILS_ENV = ENV['RAILS_ENV'] = ARGV.first
end

require File.expand_path('../config/application', __FILE__)


DC::Application.load_tasks
