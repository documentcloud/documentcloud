desc "Deploy via git to ec2 staging"
task :deploy do
  user = RAILS_ENV == 'staging' ? 'root' : 'ubuntu'
  dir  = RAILS_ENV == 'staging' ? '/web/document-cloud' : '~/document-cloud'
  host = "#{RAILS_ENV}.dcloud.org"
  todo = []
  todo << 'cd /web/document-cloud'
  todo << 'git pull'
  todo << "su www-data -c \"jammit -u http://#{host}\""
  todo << "rake staging crowd:server:restart crowd:node:restart db:migrate app:restart app:warm"
  system "ssh -t -i config/server/keys/documentcloud.pem #{user}@#{host} '#{todo.join(' && ')}'"
end
