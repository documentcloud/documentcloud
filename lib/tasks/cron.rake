namespace :cron do

  task :nightly do
    invoke 'db:backup'
  end

  task :hourly do
    invoke 'app:publish'
  end

end


private

def invoke(name)
  Rake::Task[name].invoke
end