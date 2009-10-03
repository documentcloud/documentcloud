namespace :db do
  
  desc "completely wipe out all existing data stores"
  task :delete_datastores => :environment do
    DC::Store::AssetStore.new.delete_database!
    DC::Store::EntryStore.new.delete_database!
    DC::Store::FullTextStore.new.delete_database!
    DC::Store::MetadataStore.new.delete_database!
    DC::Store::EntryStore.new.open_for_writing { }
    DC::Store::MetadataStore.new.open_for_writing { }
  end
  
  namespace :tyrant do
  
    desc "start up all our Tokyo Tyrant servers"
    task :start => :environment do
      entry_path  = File.expand_path("#{RAILS_ROOT}/db/#{RAILS_ENV}_entries.tct")
      meta_path   = File.expand_path("#{RAILS_ROOT}/db/#{RAILS_ENV}_metadata.tct")
      entry_pid   = File.expand_path("#{RAILS_ROOT}/tmp/pids/#{RAILS_ENV}_entries.pid")
      meta_pid    = File.expand_path("#{RAILS_ROOT}/tmp/pids/#{RAILS_ENV}_metadata.pid")
      `ttserver -dmn -port #{DC_CONFIG['entry_store_port']} -pid #{entry_pid} #{entry_path}`
      `ttserver -dmn -port #{DC_CONFIG['metadata_store_port']} -pid #{meta_pid} #{meta_path}`
    end
  
    desc "stop all our Tokyo Tyrant servers"
    task :stop do
      `kill #{File.read("#{RAILS_ROOT}/tmp/pids/#{RAILS_ENV}_entries.pid")}`
      `kill #{File.read("#{RAILS_ROOT}/tmp/pids/#{RAILS_ENV}_metadata.pid")}`
    end
  
    desc "restart all our Tokyo Tyrant servers"
    task :restart => [:stop, :start]
        
  end
  
end