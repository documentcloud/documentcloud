namespace :app do

  task :start do
    fallback("nginx", "thin -e #{RAILS_ENV} -p #{port_number} -d start")
  end

  task :run do
    sh "thin -e #{RAILS_ENV} -p #{port_number} start"
  end

  task :stop do
    fallback("killall nginx", "thin stop -f")
  end

  task :restart => [:stop, :start]

end

def fallback(real, development)
  sh(RAILS_ENV == 'development' ? development : real)
end

def port_number
  RAILS_ENV == 'development' ? '3000' : '80'
end