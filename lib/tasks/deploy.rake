namespace :deploy do

  desc "Deploy and migrate the database, then restart CloudCrowd"
  task :full do
    run_deploy(["app:update", "app:jammit", "db:migrate", "app:restart", "app:warm"], app_servers)
    run_deploy(["app:update", "crowd:server:restart"], central_servers)
    run_deploy(["app:update", "crowd:node:restart"], worker_servers)
  end

  desc "Deploy the Rails application"
  task :app do
    run_deploy(["app:update", "app:jammit", "app:restart", "app:warm"], app_servers)
  end

end


private

def app_servers
  case RAILS_ENV
  when 'staging'    then ['staging.dcloud.org']
  when 'production' then ['app01.documentcloud.org']
  end
end

def central_servers
  case RAILS_ENV
  when 'staging'    then ['staging.dcloud.org']
  when 'production' then ['db01.documentcloud.org']
  end
end

def worker_servers
  case RAILS_ENV
  when 'staging'    then ['staging.dcloud.org']
  when 'production' then ['db01.documentcloud.org', 'worker01.documentcloud.org']
  end
end

def configuration
  case RAILS_ENV
  when 'staging'    then {:user => 'root', :dir => '/web/document-cloud', :key => 'config/server/keys/staging.pem'}
  when 'production' then {:user => 'ubuntu', :dir => '~/document-cloud', :key => 'config/server/keys/documentcloud.pem'}
  end
end

def run_deploy(commands, machines)
  conf = configuration
  todo = []
  todo << "cd #{conf[:dir]}"
  todo << "rake #{RAILS_ENV} #{commands.join(' ')}"
  machines.each do |host|
    system "ssh -t -i #{conf[:key]} #{conf[:user]}@#{host} '#{todo.join(' && ')}'"
  end
end
