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
      sh "killall nginx" if File.exists?('/var/run/nginx.pid')
    end
  end

  task :restart => [:stop, :start]

end

def port_number
  RAILS_ENV == 'development' ? '3000' : '80'
end
