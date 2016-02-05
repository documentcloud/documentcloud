jammit_config = YAML.load ERB.new(File.read(File.join(Rails.root, 'config', 'assets.yml'))).result(binding)

engines = DC::Application.railties.select{ |t| t.kind_of? Rails::Engine and t.respond_to? :jammit_config }
engines.each do |engine|
  engine_jammit_config = engine.jammit_config
  jammit_config["javascripts"] = jammit_config["javascripts"].merge(engine_jammit_config["javascripts"])
  jammit_config["stylesheets"] = jammit_config["stylesheets"].merge(engine_jammit_config["stylesheets"])
  jammit_config["asset_roots"] = [jammit_config["asset_roots"], engine_jammit_config["asset_roots"]].flatten.compact.uniq
end

Jammit.load_configuration(jammit_config)

module Jammit
  def self.reload!
  end
end
