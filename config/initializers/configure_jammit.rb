module DC
  def self.jammit_configuration
    jammit_config_paths = []
    
    engines = DC::Application.railties.select{ |t| t.kind_of? Rails::Engine and t.respond_to? :jammit_config_path }
    engines.each do |engine|
      jammit_config_paths.push engine.jammit_config_path
    end
    jammit_config_paths.push File.join(Rails.root, 'config', 'assets.yml')
    jammit_config_paths
  end
end

Jammit.load_configuration(DC.jammit_configuration)

module Jammit
  def self.reload!
  end
end
