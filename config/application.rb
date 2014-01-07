require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)


module DC

  SECRETS   = {}
  CONFIG = {}

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # DocumentCloud-specific configuration.
    ::DC::SECRETS.merge!   YAML.load_file(Rails.root.join('config','server', 'secrets/secrets.yml'))[Rails.env]
    ::DC::CONFIG.merge! YAML.load( ERB.new(File.read( Rails.root.join('config','document_cloud.yml') ) ).result )[Rails.env]

    ::DC::ANALYTICS_DB = YAML.load(ERB.new(File.read("#{Rails.root}/config/database_analytics.yml")).result(binding))[Rails.env]
    ::DC::MAIN_DB      = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result(binding))[Rails.env]

    config.filter_parameters += [:password]

  end
end
