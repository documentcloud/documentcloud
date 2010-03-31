namespace :crowd do

  task :console do
    sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} console"
  end

  [:server, :node].each do |resource|
    namespace resource do

      task :stop do
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} #{resource} stop"
      end

      task :run do
        port = (resource == :server) ? '-p 8080' : ''
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} #{port} #{resource} start"
      end

      task :start do
        port = (resource == :server) ? '-p 8080' : ''
        sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} #{port} -d #{resource} start"
      end

      task :restart => [:stop, :start]

    end
  end

end


