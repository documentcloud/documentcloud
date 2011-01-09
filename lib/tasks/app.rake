namespace :app do

  task :start do
    sh "sudo /etc/init.d/nginx start"
  end

  task :devstart do
    sh "rake crowd:server:start && rake crowd:node:start && rake sunspot:solr:start && sudo nginx"
  end

  task :stop do
    sh "sudo /etc/init.d/nginx stop"
  end

  task :restart do
    sh "touch tmp/restart.txt"
  end

  task :warm do
    sh "curl -s -u guest:docsforall http://localhost:80 > /dev/null"
  end

  task :console do
    exec "script/console #{RAILS_ENV}"
  end

  desc "Update the Rails application"
  task :update do
    sh 'git pull'
    sleep 0.2
  end

  desc "Repackage static assets"
  task :jammit do
    config = YAML.load_file("#{Rails.root}/config/document_cloud.yml")[RAILS_ENV]
    sh "sudo su www-data -c \"jammit -u http://#{config['server_root']}\""
  end

  desc "Publish all documents with expired publish_at timestamps"
  task :publish, :needs => :environment do
    Document.publish_due_documents
  end

  desc "Clears out cached document JS files."
  task :clearcache do
    files = Dir["./public/documents/*.js"]
    sh "rm ./public/documents/*.js" if files.length
  end

end

namespace :openoffice do

  task :start do
    utility = RUBY_PLATFORM.match(/darwin/) ? "/Applications/OpenOffice.org.app/Contents/MacOS/soffice.bin" : "soffice"
    sh "#{utility} -headless -accept=\"socket,host=127.0.0.1,port=8100;urp;\" -nofirststartwizard"
  end

end

# def nginx_pid
#   pid_locations = ['/var/run/nginx.pid', '/usr/local/nginx/logs/nginx.pid', '/opt/nginx/logs/nginx.pid']
#   @nginx_pid ||= pid_locations.detect {|pid| File.exists?(pid) }
# end

