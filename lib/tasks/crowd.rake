namespace :crowd do

  [:server, :node].each do |resource|
    namespace resource do
      
      task :stop do
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} #{resource} stop"
      end
      
      task :run do
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} #{crowd_port} #{resource} start"
      end
      
      task :start do
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} #{crowd_port} -d #{resource} start"
      end
      
      task :restart => [:stop, :start]
      
    end
  end

end

def crowd_port
  (RAILS_ENV == 'staging' && resource == :server) ? '-p 8080' : ''
end  

