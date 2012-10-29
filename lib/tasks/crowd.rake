namespace :crowd do

  task :console do
    sh "crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} console"
  end

  [:server, :node].each do |resource|
    namespace resource do

      desc "Stop the crowdcloud #{resource.to_s}"
      task :stop do
        sh "crowd -c config/cloud_crowd/#{crowd_folder} -e #{RAILS_ENV} #{resource} stop"
      end

      desc "Run the crowdcloud #{resource.to_s} in the foreground"
      task :run do
        port = (resource == :server) ? '-p 8080' : ''
        sh "crowd -c config/cloud_crowd/#{crowd_folder} -e #{RAILS_ENV} #{port} #{resource} start"
      end

      desc "Start the crowdcloud #{resource.to_s}"
      task :start do
        port = (resource == :server) ? '-p 8080' : ''
        sh "crowd -c config/cloud_crowd/#{crowd_folder} -e #{RAILS_ENV} #{port} -d #{resource} start"
      end

      desc "Restart the crowdcloud #{resource.to_s}"
      task :restart => [:stop, :start]

    end
  end
  
  namespace :node do 
    desc "Handy unix shotgun for culling zombie crowd worker processes"
    task :cull do
      `ps aux | grep crowd | ruby -e 'STDIN.read.split("\n").each{ |line| puts line.split[1] unless line =~ /rake/ }' | xargs kill`
    end
  end
  

end

def crowd_folder
  File.exists?('EXPRESS') ? 'express' : RAILS_ENV
end



