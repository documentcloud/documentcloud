namespace :app do
  
  task :start do
    sh "thin -e #{RAILS_ENV} -p #{port_number} -d start"
  end
  
  task :run do
    sh "thin -e #{RAILS_ENV} -p #{port_number} start"
  end
  
  task :stop do
    sh 'thin stop -f'
  end
  
  task :restart => [:stop, :start]
  
end

def port_number
  RAILS_ENV == 'development' ? '3000' : '80'
end