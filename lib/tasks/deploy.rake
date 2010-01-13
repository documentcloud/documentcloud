desc "Deploy via git to ec2 staging"
task :deploy do
  user = RAILS_ENV == 'staging' ? 'root' : 'ubuntu'
  dir  = RAILS_ENV == 'staging' ? '/web/document-cloud' : '~/document-cloud'
  host = "#{RAILS_ENV}.dcloud.org"
  todo = []
  todo << "cd #{dir}"
  todo << 'git pull'
  todo << "sudo su www-data -c \"jammit -u http://#{host}\""
  todo << "rake staging crowd:server:restart crowd:node:restart db:migrate app:restart app:warm"
  system "ssh -t -i config/server/keys/documentcloud.pem #{user}@#{host} '#{todo.join(' && ')}'"
end
