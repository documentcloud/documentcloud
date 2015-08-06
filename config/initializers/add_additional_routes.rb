module DC
  class Application
    def self.load_additional_routes
      engines = Rails.application.railties.select{ |t| t.kind_of? Rails::Engine }
      engines.each do |engine|
        engine.load_routes if engine.respond_to? :load_routes
      end
    end
  end
end