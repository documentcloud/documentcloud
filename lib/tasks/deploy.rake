# TODO: Synchronize staging's old AMI / setup with the new one.

desc "Deploy via Git to EC2"
task :deploy do
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
  todo << "rake #{RAILS_ENV} crowd:server:restart crowd:node:restart db:migrate app:restart app:warm"
  system "ssh -t -i #{key} #{user}@#{host} '#{todo.join(' && ')}'"
end
