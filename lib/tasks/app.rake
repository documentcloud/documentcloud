namespace :app do

  task :start do
    sh "nginx"
  end

  task :run do
    sh "thin -e #{RAILS_ENV} -p 3000 start"
  end

  task :stop do
    sh "kill #{File.read(nginx_pid)}" if File.exists?(nginx_pid)
  end

  task :restart do
    sh "touch tmp/restart.txt"
  end

  task :warm do
    sh "curl -s -u guest:docsforall http://localhost:80 > /dev/null"
  end

end

def nginx_pid
  '/var/run/nginx.pid'
end

