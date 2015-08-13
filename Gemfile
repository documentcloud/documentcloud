source 'https://rubygems.org'

def you_are_documentcloud?
  File.exists? File.join(File.dirname(__FILE__), 'secrets', 'documentcloud.yep')
end

if you_are_documentcloud?
  gem "bull_proof_china_shop", :git => "git@github.com:documentcloud/bull_proof_china_shop"
  gem 'stripe',               '~> 1.24.0'
end

gem 'iconv'
gem 'rails',                  '~> 4.2.0'
gem 'curb',                   '~> 0.8.4'
gem 'calais',                 '~> 0.0.13', :github => 'nathanstitt/calais', :branch => 'newer_nokogiri'
gem 'rest-client',            '~> 1.8.0'
gem 'bcrypt',                 '~> 3.1.1', :require => 'bcrypt'
gem 'rubyzip',                '~> 1.1.0'
gem 'aws-sdk',                '~> 1.30', :require => 'aws'
gem 'pg'

gem 'closure-compiler'
gem 'docsplit',               '0.8.0.alpha1'
gem 'sunspot_rails',          '~> 2.1.0'
gem 'sunspot_solr',           '~> 2.1.0'
# Optional, used by sunspot to show progress while re-indexing
gem 'progress_bar'
gem 'cloud-crowd',            '~> 0.7.3'
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
gem 'jammit',                 :github => 'documentcloud/jammit'
gem 'nokogiri',               '~> 1.6.0'
gem 'net-ssh-shell'
gem 'country_select',         '~> 2.2.0'

group :development, :test do
  gem 'guard-bundler'
  gem 'growl'
  gem 'sunspot_matchers'
  gem 'minitest'
  gem 'minitest-spec-rails'
  gem 'guard-minitest'
  gem 'spring'
  # For downloading the translations from google spreadsheet
  gem 'google_drive',         '~> 1.0.0'
  # Securely ask for username/password for access to translation spreadsheet
  gem 'highline'
  gem 'pry'
  # Debugger
  gem 'byebug'
  gem 'ruby-debug-passenger'
end
