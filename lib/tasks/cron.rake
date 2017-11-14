namespace :cron do

  # Only run on db01
  task :nightly do
    invoke 'crowd:cluster:free_calais_blacklist'
    invoke 'db:backup' unless you_are_documentcloud?
    invoke 'db:vacuum_analyze'
    invoke 'mail:csv'
  end

  # Only run on db01
  task :hourly do
    invoke 'app:publish'
  end

  # Only run on app01
  task :minutely do
    invoke 'app:clearcache:search' if Time.now.min % 5 == 0 # Every 5 min
  end

end


private

def invoke(name)
  Rake::Task[name].invoke
end

def you_are_documentcloud?
  File.exists? File.join(Rails.root, 'secrets', 'documentcloud.yep')
end
