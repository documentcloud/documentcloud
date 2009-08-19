SECRETS = YAML.load_file("#{RAILS_ROOT}/config/secrets.yml")[RAILS_ENV]

module DC
  CONFIG = YAML.load_file("#{RAILS_ROOT}/config/document_cloud.yml")[RAILS_ENV]
end