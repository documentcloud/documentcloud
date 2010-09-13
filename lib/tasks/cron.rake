namespace :cron do

  task :nightly do
    invoke 'db:backup'
    invoke 'db:update_remote_urls'
  end

end


private

def invoke(name)
  Rake::Task[name].invoke
end