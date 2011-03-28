namespace :cron do

  task :nightly do
    invoke 'db:backup'
    invoke 'mail:csv'
  end

  task :hourly do
    invoke 'app:publish'
  end

  task :minutely do
    invoke 'app:clearcache:search' if Time.now.min % 5 == 0 # Every 5 min
  end

end


private

def invoke(name)
  Rake::Task[name].invoke
end