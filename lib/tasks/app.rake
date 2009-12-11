namespace :app do

  task :start do
    sh "sudo nginx"
  end

  task :stop do
    sh "sudo kill #{File.read(nginx_pid)}" if nginx_pid
  end

  task :restart do
    sh "touch tmp/restart.txt"
  end

  task :warm do
    sh "curl -s -u guest:docsforall http://localhost:80 > /dev/null"
  end

end

def nginx_pid
  pid_locations = ['/var/run/nginx.pid', '/usr/local/nginx/logs/nginx.pid']
  @nginx_pid ||= pid_locations.detect {|pid| File.exists?(pid) }
end

