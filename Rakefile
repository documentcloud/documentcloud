# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

if ['test','development','staging','production'].include?(ARGV.first)
    environment = ARGV.first
    if ENV['RAILS_ENV'] && ENV['RAILS_ENV'] != environment
        STDERR.puts "RAILS_ENV was set to #{ENV['RAILS_ENV']}, but the environment specified was #{environment}"
        exit 1
    end
    RAILS_ENV = ENV['RAILS_ENV'] = environment
end

require File.expand_path('../config/application', __FILE__)


DC::Application.load_tasks
