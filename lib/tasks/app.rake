namespace :app do

  namespace :backup do

    desc "Backup a file to the asset store that corresponds to the current environment."
    task :logfile, [:type, :src_file]=>:environment do |t, args|
      source = args[:src_file]
      source_name = File.basename(source)
      target_name = source_name.sub(/\.1(\.gz)?$/, ($1||""))
      target_path = "#{args[:type]}/#{Date.today}.#{`hostname`.chomp}.#{target_name}"
      DC::Store::AssetStore.new.save_backup(args[:src_file], target_path)
    end

  end

  task :start do
    sh "sudo /etc/init.d/nginx start"
  end

  task :devstart do
    invoke 'sunspot:solr:start'
    invoke 'crowd:server:start'
    invoke 'crowd:node:start'
  end

  task :devrestart do
    invoke 'app:restart'
    invoke 'crowd:node:restart'
  end

  task :restart_solr do
    invoke "sunspot:solr:stop"
    invoke "sunspot:solr:start"
  end

  task :stop do
    sh "sudo /etc/init.d/nginx stop"
  end

  task :restart do
    sh "touch tmp/restart.txt"
  end

  task :warm do
    secrets = YAML.load_file("#{Rails.root}/secrets/secrets.yml")[RAILS_ENV]
    sh "curl -s -u #{secrets['guest_username']}:#{secrets['guest_password']} http://localhost:80 > /dev/null"
  end

  task :console do
    exec "rails console #{RAILS_ENV}"
  end

  desc "Update the Rails application"
  task :update do
    sh 'cd secrets && git pull && cd ..'
    sh 'git pull'
    sleep 0.2 # TODO: make this event driven not just waiting for .2 seconds
    sh 'bundle install'
  end

  desc "Update Bower dependencies"
  task :bower do
    options = ['-F']
    options.push "--production" if Rails.env.staging? or Rails.env.production?
    sh "bower install #{options.join(' ')}"
  end

  desc "Repackage static assets"
  task :jammit do
    require File.join(Rails.root, 'config', 'initializers', 'configure_jammit')
    config = YAML.load(ERB.new(File.read("#{Rails.root}/config/document_cloud.yml")).result(binding))[Rails.env]
    #sh "jammit -u http://#{config['server_root']}"
    Jammit.package!(base_url: "http://#{config['server_root']}", config_paths: DC.jammit_configuration)
  end

  desc "Publish all documents with expired publish_at timestamps"
  task :publish => :environment do
    Document.publish_due_documents
  end

end

# def nginx_pid
#   pid_locations = ['/var/run/nginx.pid', '/usr/local/nginx/logs/nginx.pid', '/opt/nginx/logs/nginx.pid']
#   @nginx_pid ||= pid_locations.detect {|pid| File.exists?(pid) }
# end

