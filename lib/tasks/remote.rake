# Common configuration for remote servers.

namespace :remote do

  desc "Open a Remote Rails Console"
  task :console do
    remote "app:console", central_servers
  end

  task :start do
    remote "app:start", app_servers
  end

  desc "Start all resources, on all servers"
  task :start_all do
    remote "db:start", central_servers
    remote "sunspot:solr:start", central_servers
    remote "crowd:server:start", central_servers
    remote "crowd:node:start", worker_servers
    remote "openoffice:start", app_servers
    remote "app:start", app_servers
  end

end

# SSH into a given remote machine. Need to pass the environment.
rule(/^ssh:/) do |t|
  conf = configuration
  host = t.name.split(':').last
  exec "ssh -A -i #{conf[:key]} #{conf[:user]}@#{host}.documentcloud.org"
end

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
  when 'production' then ['worker01.documentcloud.org', 'worker02.documentcloud.org']
  end
end

def configuration
  case RAILS_ENV
  when 'staging'    then {:user => 'root', :dir => '/web/document-cloud', :key => 'config/server/keys/staging.pem'}
  when 'production' then {:user => 'ubuntu', :dir => '~/document-cloud', :key => 'config/server/keys/documentcloud.pem'}
  end
end

def remote(commands, machines)
  commands = [commands].flatten
  conf = configuration
  todo = []
  todo << "cd #{conf[:dir]}"
  todo << "rake #{RAILS_ENV} #{commands.join(' ')}"
  machines.each do |host|
    system "ssh -A -t -i #{conf[:key]} #{conf[:user]}@#{host} '#{todo.join(' && ')}'"
  end
end
