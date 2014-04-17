# Keep the entire DC namespace unloadable in development, so that most of the
# /lib folder code will be refreshed for each request.
# ActiveSupport::Dependencies.explicitly_unloadable_constants << 'DC'



require 'dc'

# ANALYTICS_DB = YAML.load(ERB.new(File.read("#{Rails.root}/config/database_analytics.yml")).result(binding))[Rails.env]
# MAIN_DB      = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result(binding))[Rails.env]

# require 'lib/dc'
# require 'lib/dc/i18n'
# require 'lib/dc/sanitized'

