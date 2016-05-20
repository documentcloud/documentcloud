require_relative '../../config/initializers/aws'
require_relative '../dc/aws'
require_relative '../dc/cloud_crowd'

namespace :crowd do

  task :console do
    sh "./bin/crowd -c config/cloud_crowd/#{RAILS_ENV} -e #{RAILS_ENV} console"
  end
  
  task :load_schema do
    sh "./bin/crowd -c config/cloud_crowd/#{crowd_folder} -e #{RAILS_ENV} load_schema"
  end

  [:server, :node].each do |resource|
    namespace resource do

      desc "Stop the crowdcloud #{resource.to_s}"
      task :stop do
        sh "./bin/crowd -c config/cloud_crowd/#{crowd_folder} -e #{RAILS_ENV} #{resource} stop"
      end

      desc "Run the crowdcloud #{resource.to_s} in the foreground"
      task :run do
        port = (resource == :server) ? '-p 8080' : ''
        sh "./bin/crowd -c config/cloud_crowd/#{crowd_folder} -e #{RAILS_ENV} #{port} #{resource} start"
      end

      desc "Start the crowdcloud #{resource.to_s}"
      task :start do
        port = (resource == :server) ? '-p 8080' : ''
        sh "./bin/crowd -c config/cloud_crowd/#{crowd_folder} -e #{RAILS_ENV} #{port} -d #{resource} start"
      end

      desc "Restart the crowdcloud #{resource.to_s}"
      task :restart => [:stop, :start]

    end
  end

  namespace :node do
    desc "Handy unix shotgun for culling zombie crowd worker processes"
    task :cull do
      `ps aux | egrep "crowd|pdftk|pdftailor|tesseract|gm|soffice" | ruby -e 'STDIN.read.split("\n").each{ |line| puts line.split[1] unless line =~ /rake|grep/ }' | xargs kill`
      `if [ -e tmp/pids/node.pid ] ; then rm tmp/pids/node.pid ; fi`
    end

    task :cleanup_tmp do
      `rm -rf /tmp/cloud_crowd_tmp/*; rm -rf /tmp/d#{Time.now.year}*`
    end
  end

  namespace :cluster do
    [:list_processes, :start_nodes, :kill_nodes].each do |command|
      task(command){ CloudCrowd::NodeWrangler.new.send(command) }
    end

    desc "Launch nodes on the cluster"
    task(:launch_nodes, :count, :node_name) do |t, options|
      CloudCrowd::NodeWrangler.new.launch_nodes(options)
    end
    
    desc "Remove blacklist on Open Calais for daily limit reset"
    task :free_calais_blacklist => :environment do
      begin
        RestClient.delete File.join(DC::CONFIG['cloud_crowd_server'],"blacklist","reprocess_entities")
      rescue RestClient::ResourceNotFound => e
        # it's fine if reprocess_entities isn't on the blacklist.
      end
      AppConstant.replace("calais_calls_made", 0.to_s)
    end
  end
end



def crowd_folder
  case
    when File.exists?('EXPRESS')
      'express'
    when File.exists?('REINDEX')
      'reindex'
    when File.exists?('API')
      'api'
    else
      Rails.env
  end
end
