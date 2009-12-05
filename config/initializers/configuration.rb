SECRETS = YAML.load_file("#{Rails.root}/config/secrets.yml")[RAILS_ENV]

DC_CONFIG = YAML.load_file("#{Rails.root}/config/document_cloud.yml")[RAILS_ENV]
