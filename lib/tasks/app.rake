namespace :app do

  task :start do
    if RAILS_ENV == 'development'
      sh "thin -e #{RAILS_ENV} -p #{port_number} -d start"
    else
      sh "nginx"
    end
  end

  task :run do
    sh "thin -e #{RAILS_ENV} -p #{port_number} start"
  end

  task :stop do
    if RAILS_ENV == 'development'
      sh "thin stop -f"
    else
      sh "kill #{File.read(nginx_pid)}" if File.exists?(nginx_pid)
    end
  end

  task :restart do
    if RAILS_ENV == 'development'
      sh "thin stop -f && thin -e #{RAILS_ENV} -p #{port_number} -d start"
    else
      sh "touch tmp/restart.txt"
    end
  end

end

def nginx_pid
  '/var/run/nginx.pid'
end

def port_number
  RAILS_ENV == 'development' ? '3000' : '80'
end
