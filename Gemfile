source 'https://rubygems.org'
gem 'iconv'
gem 'rails',                  '~>4.2.0'
gem 'curb',                   '~>0.8.4'
gem 'open_calais',            :github => "documentcloud/open_calais", :branch=> "fuzziness" # Supports Open Calais v2
gem 'rest-client',            '~> 1.8.0'
gem 'bcrypt',                 '~> 3.1.1', :require => 'bcrypt'
gem 'rubyzip',                '~> 1.1.0' #0.9.9'
gem 'aws-sdk',                '~> 1.30', :require => 'aws' #11.1'
gem 'pg'

gem 'closure-compiler'
gem 'docsplit',               '0.8.0.alpha1'
gem 'sunspot_rails',          '~> 2.1.0'
gem 'sunspot_solr',           '~> 2.1.0'
gem 'progress_bar'  # optional, used by sunspot to show progress while re-indexing
gem 'cloud-crowd',            :github => 'documentcloud/cloud-crowd', :branch => 'blacklist'
gem 'pdftailor'
gem 'pdfshaver'

gem 'omniauth',               '~> 1.2.1'
gem 'omniauth-twitter',       '~> 1.0'
gem 'omniauth-facebook',      '~> 1.6'
gem 'omniauth-google-oauth2', '~> 0.2'
gem 'sanitize',               '~> 2.0.6'
gem 'rdiscount',              '~> 2.1.6'
gem 'rake'
gem 'actionpack-page_caching'
gem 'jammit',                 :github=>'documentcloud/jammit'
gem 'nokogiri',               '~> 1.6.0'
gem 'net-ssh-shell'
gem 'country_select',         '~> 2.2.0'

group :development, :test do
  gem 'guard-bundler'
  gem 'growl'
  gem "sunspot_matchers"
  gem 'minitest'
  gem 'minitest-spec-rails'
  gem 'guard-minitest'
  gem 'spring'
  # for downloading the translations from google spreadsheet
  gem 'google_drive',         '~> 1.0.0'
  # securely ask for username/password for access to translation spreadsheet
  gem 'highline'
  gem "pry"
  gem "byebug" # Debugger
  gem 'factory_girl_rails' # Mocking out objects
  gem "ruby-debug-passenger"
  gem 'vcr'
end
