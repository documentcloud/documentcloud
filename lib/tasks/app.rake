namespace :app do
  
  task :start do
    port = RAILS_ENV == 'development' ? '3000' : '80'
    sh "thin -e #{RAILS_ENV} -p #{port} -d start"
  end
  
  task :stop do
    sh 'thin stop'
  end
  
end