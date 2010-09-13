namespace :cron do

  task :nightly do
    invoke 'db:backup'
  end

end


private

def invoke(name)
  Rake::Task[name].invoke
end