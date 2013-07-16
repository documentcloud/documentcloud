namespace :crowd do

  task :console do
    sh "crowd -c config/cloud_crowd/#{Rails.env} -e #{Rails.env} console"
  end

  [:server, :node].each do |resource|
    namespace resource do

      desc "Stop the crowdcloud #{resource.to_s}"
      task :stop do
        sh "crowd -c config/cloud_crowd/#{crowd_folder} -e #{Rails.env} #{resource} stop"
      end

      desc "Run the crowdcloud #{resource.to_s} in the foreground"
      task :run do
        port = (resource == :server) ? '-p 8080' : ''
        sh "crowd -c config/cloud_crowd/#{crowd_folder} -e #{Rails.env} #{port} #{resource} start"
      end

      desc "Start the crowdcloud #{resource.to_s}"
      task :start do
        port = (resource == :server) ? '-p 8080' : ''
        sh "crowd -c config/cloud_crowd/#{crowd_folder} -e #{Rails.env} #{port} -d #{resource} start"
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
  File.exists?('EXPRESS') ? 'express' : Rails.env
end



