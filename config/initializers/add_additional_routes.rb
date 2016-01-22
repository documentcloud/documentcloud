module DC
  class Application
    def load_additional_routes
      engines = self.railties.select{ |t| t.kind_of? Rails::Engine }
      engines.each do |engine|
        engine.load_routes if engine.respond_to? :load_routes
      end
    end
  end
end