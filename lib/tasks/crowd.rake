namespace :crowd do

  [:server, :node].each do |resource|
    namespace resource do
      
      task :stop do
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} #{resource} stop"
      end
      
      task :start do
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -d #{resource} start"
      end
      
    end
  end

end
