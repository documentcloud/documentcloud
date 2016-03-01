desc 'Test Coverage for all test suites'
namespace :test do
  task :coverage do
    require 'simplecov'
    
    SimpleCov.profiles.define 'documentcloud_combined' do
      load_profile 'rails'

      add_group 'DC Lib', 'lib/dc'
      add_group 'Actions', 'actions'
      add_group "Long files" do |src_file|
        src_file.lines.count > 100
      end

      add_filter 'vendor'
      add_filter 'solr'
    end
    SimpleCov.start 'documentcloud_combined'
    Rake::Task["test"].execute
    system("export DISPLAY=:99.0 && bundle exec rspec")
  end
end
