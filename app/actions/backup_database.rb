require File.dirname(__FILE__) + '/support/setup'

class BackupDatabase < CloudCrowd::Action

  def process
    date      = Date.today.to_s
    config    = Rails::Configuration.new.database_configuration[Rails.env]
    db        = MAIN_DB[Rails.env]['database']
    host      = config['host'] ? "-h #{config['host']}" : ''
    username  = config['username']
    pass      = config['password']
    Dir.mktmpdir do |temp_dir|
      dump    = File.join(temp_dir, "#{db}.dump")
      system "PGPASSWORD=\"#{pass}\" pg_dump -U #{username} #{host} -Fc #{db} > #{dump}"
      DC::Store::AssetStore.new.save_database_backup('dcloud', dump)
      db      = ANALYTICS_DB[Rails.env]['database']
      dump    = File.join(temp_dir, "#{db}.dump")
      system "PGPASSWORD=\"#{pass}\" pg_dump -U #{username} #{host} -Fc #{db} > #{dump}"
      DC::Store::AssetStore.new.save_database_backup('analytics', dump)
    end
    true
  end

end