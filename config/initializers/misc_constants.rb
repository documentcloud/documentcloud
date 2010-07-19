# Keep the entire DC namespace unloadable in development, so that most of the
# /lib folder code will be refreshed for each request.
# ActiveSupport::Dependencies.explicitly_unloadable_constants << 'DC'

ANALYTICS_DB = YAML.load_file("#{Rails.root}/config/database_analytics.yml")[Rails.env]
MAIN_DB = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]
require 'lib/dc'
