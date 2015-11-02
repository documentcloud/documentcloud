source 'https://rubygems.org'
gem 'iconv'
gem 'rails',                  '~>4.2.0'
gem 'curb',                   '~>0.8.4'
gem 'open_calais',            :github => 'documentcloud/open_calais', :branch => 'fuzziness' # Supports Open Calais v2
gem 'rest-client',            '~> 1.8.0'
gem 'bcrypt',                 '~> 3.1.1', :require => 'bcrypt'
gem 'rubyzip',                '~> 1.1.0'
gem 'aws-sdk',                '~> 1.30', :require => 'aws'
gem 'pg'

gem 'closure-compiler'
gem 'docsplit',               '0.8.0.alpha1'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'progress_bar' # Optional, used by sunspot to show progress while re-indexing
gem 'cloud-crowd',            '~>0.7.6'
gem 'pdftailor'
gem 'pdfshaver',              '>=0.0.2'

gem 'omniauth',               '~> 1.2.1'
gem 'omniauth-twitter',       '~> 1.0'
gem 'omniauth-facebook',      '~> 1.6'
gem 'omniauth-google-oauth2', '~> 0.2'
gem 'sanitize',               '~> 2.0.6'
gem 'rdiscount',              '~> 2.1.6'
gem 'rake'
gem 'actionpack-page_caching'
gem 'jammit',                 '~> 0.7.0'
gem 'nokogiri',               '~> 1.6.0'
gem 'net-ssh-shell'
gem 'country_select',         '~> 2.2.0'

group :development, :test do
  gem 'guard-bundler'
  gem 'growl'
  gem 'sunspot-rails-tester'
  #gem 'sunspot_matchers'
  gem 'spring'
  gem 'pry'
  gem 'byebug' # Debugger
  gem 'factory_girl_rails' # Mocking out objects
  gem 'ruby-debug-passenger'
end

group :development do
  # `google_drive` and `highline` are development-only because we use them to
  # access/compile the translations spreadsheet, and this should only be done
  # by a developer on their local machine before committing the compiled strings
  gem 'google_drive',         '~> 1.0.0'
  gem 'highline'
end

group :test do
  gem 'minitest'
  gem 'minitest-spec-rails'
  gem 'guard-minitest'
  gem 'vcr'
  gem 'webmock'
end
