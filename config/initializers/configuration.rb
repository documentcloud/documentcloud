SECRETS = YAML.load_file("#{RAILS_ROOT}/config/secrets.yml")[RAILS_ENV]

DC_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/document_cloud.yml")[RAILS_ENV]

ASSET_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/assets.yml")