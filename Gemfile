source 'https://rubygems.org'

def you_are_documentcloud?
  File.exists? File.join(File.dirname(__FILE__), 'secrets', 'documentcloud.yep')
end

if you_are_documentcloud?
  # Must include branch explicitly for bundler's local config override
  gem 'bull_proof_china_shop',
      git:    'git@github.com:documentcloud/bull_proof_china_shop',
      branch: 'master'
end

gem 'iconv'
gem 'rails',                  '~>4.2.0'
gem 'curb',                   '~>0.8.4'
gem 'open_calais',            git:    'https://github.com/documentcloud/open_calais.git',
                              branch: 'fuzziness' # Supports Open Calais v2
gem 'rest-client',            '~> 1.8.0'
gem 'bcrypt',                 '~> 3.1.1', require: 'bcrypt'
gem 'rubyzip',                '~> 1.1.0'
gem 'aws-sdk',                '~> 1.30',  require: 'aws'
gem 'pg'

gem 'closure-compiler'
gem 'sunspot_rails',          '2.2.0'
gem 'sunspot_solr',           '2.2.0'
gem 'progress_bar' # Optional, used by sunspot to show progress while re-indexing

# TODO: omniauth cleanup remove me
# gem 'omniauth',               
# gem 'omniauth-twitter',       '~> 1.0'
# gem 'omniauth-facebook',      '~> 1.6'
# gem 'omniauth-google-oauth2', '~> 0.2'

# Auth
gem 'omniauth', '~> 1.3.1'
gem 'omniauth-oauth2'

gem 'sanitize',               '~> 2.0.6'
gem 'rdiscount',              '~> 2.1.6'
gem 'rake'
gem 'actionpack-page_caching'
gem 'jammit',                 git: 'https://github.com/documentcloud/jammit.git',
                              branch: 'master'
gem 'nokogiri',               '~> 1.6.0'
gem 'net-ssh-shell'
gem 'country_select',         '~> 2.2.0'
gem 'bootstrap_form',         git:    'https://github.com/documentcloud/rails-bootstrap-forms.git',
                              branch: 'bootstrap-v4'
gem 'stripe',                 '~> 1.56.2'

gem 'active_model_serializers', '~>0.9.0'
gem 'passenger'

group :development, :test do
  gem 'guard-bundler'
  gem 'growl'
  gem 'sunspot-rails-tester'
  #gem 'sunspot_matchers'
  gem 'spring'
  gem 'pry'
  gem 'pry-remote'
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
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem 'railroady'
end

group :test do
  gem 'minitest'
  gem 'minitest-spec-rails'
  gem 'guard-minitest'
  gem 'vcr'
  gem 'webmock'
end

gem 'cloud-crowd',            '~>0.7.6'
#group :pdf_processing do
  gem 'docsplit',               '0.8.0.alpha1'
  gem 'pdftailor'
  gem 'pdfshaver',              '>=0.0.2'
#end
