# TODO: Synchronize staging's old AMI / setup with the new one.

desc "Deploy via Git to EC2, including CloudCrowd restarts and migrations"
task :full_deploy do
  run_deploy("crowd:server:restart", "crowd:node:restart", "db:migrate", "app:restart", "app:warm")
end

desc "Deploy via Git to EC2, only the core application"
task :deploy do
  run_deploy("app:restart", "app:warm")
end


private

def run_deploy(commands)
  host = "#{RAILS_ENV}.dcloud.org"
  user = 'ubuntu'
  dir  = '~/document-cloud'
  key  = 'config/server/keys/documentcloud.pem'
  if RAILS_ENV == 'staging'
    user = 'root'
    dir  = '/web/document-cloud'
    key  = 'config/server/keys/staging.pem'
  end
  todo = []
  todo << "cd #{dir}"
  todo << 'git pull'
  todo << "sudo su www-data -c \"jammit -u http://#{host}\""
  todo << "rake #{RAILS_ENV} #{commands.join(' ')}"
  system "ssh -t -i #{key} #{user}@#{host} '#{todo.join(' && ')}'"
end
