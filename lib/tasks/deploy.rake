namespace :deploy do

  desc "Deploy and migrate the database, then restart CloudCrowd"
  task :full do
    remote ["app:update", "app:jammit", "db:migrate", "app:restart", "app:warm"], app_servers
    remote ["app:update", "crowd:server:restart"], central_servers
    remote ["app:update", "crowd:node:restart"], worker_servers
  end

  desc "Deploy the Rails application"
  task :app do
    remote ["app:update", "app:jammit", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy the Document Viewer to S3"
  task :viewer, :needs => :environment do
    s3 = RightAws::S3.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'], :protocol => 'http', :port => 80)
    bucket = s3.bucket('s3.documentcloud.org')
    Dir['public/viewer/**/*'].each do |file|
      next if File.directory? file
      puts "uploading #{file}"
      bucket.put("viewer/#{file.gsub('public/viewer/', '')}", File.open(file), {}, 'public-read')
    end
    DC_CONFIG['server_root'] = 'http://s3.documentcloud.org'
    contents = ERB.new(File.read('app/views/documents/loader.js.erb')).result(binding)
    bucket.put('viewer/loader.js', contents, {}, 'public-read')
  end

end
