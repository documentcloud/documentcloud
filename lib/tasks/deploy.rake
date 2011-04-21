namespace :deploy do

  desc "Deploy and migrate the database, then restart CloudCrowd"
  task :full do
    remote ["app:update", "app:jammit", "db:migrate", "app:clearcache:docs", "app:clearcache:search", "app:restart", "app:warm"], app_servers
    remote ["app:update", "app:restart_solr", "crowd:server:restart"], central_servers
    remote ["app:update", "crowd:node:restart"], worker_servers
  end

  desc "Deploy the Rails application"
  task :app do
    remote ["app:update", "app:jammit", "app:clearcache:docs", "app:clearcache:search", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy just updates to Rails code"
  task :rails do
    remote ["app:update", "app:clearcache:docs", "app:clearcache:search", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy the Document Viewer to S3"
  task :viewer, :needs => :environment do
    s3 = RightAws::S3.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'], :protocol => 'http', :port => 80)
    bucket = s3.bucket('s3.documentcloud.org')
    Dir['public/viewer/**/*'].each do |file|
      next if File.directory? file
      mimetype = MIME::Types.type_for(File.extname(file)).first
      headers = mimetype ? {'Content-type' => mimetype.content_type} : {}
      puts "uploading #{file} (#{mimetype})"
      bucket.put("viewer/#{file.gsub('public/viewer/', '')}", File.open(file), {}, 'public-read', headers)
    end
    DC_CONFIG['server_root'] = 's3.documentcloud.org'
    contents = ERB.new(File.read('app/views/documents/loader.js.erb')).result(binding)
    bucket.put('viewer/loader.js', contents, {}, 'public-read')
  end

  desc "Deploy the Search/Note Embed to S3"
  {:search => ['search_embed', 'embed'], :notes => ['note_embed', 'notes']}.each_pair do |folder, embed|
    task folder.to_sym, :needs => :environment do
      s3 = RightAws::S3.new(SECRETS['aws_access_key'], SECRETS['aws_secret_key'], :protocol => 'http', :port => 80)
      bucket = s3.bucket('s3.documentcloud.org')
      Dir['public/#{embed[0]}/**/*'].each do |file|
        next if File.directory? file
        mimetype = MIME::Types.type_for(File.extname(file)).first
        headers = mimetype ? {'Content-type' => mimetype.content_type} : {}
        puts "uploading #{file} (#{mimetype})"
        bucket.put("embed/#{file.gsub("public/#{embed[0]}", '')}", File.open(file), {}, 'public-read', headers)
      end
      DC_CONFIG['server_root'] = 's3.documentcloud.org'
      contents = ERB.new(File.read("app/views/#{embed[0]}/loader.js.erb")).result(binding)
      bucket.put("#{embed[1]}/loader.js", contents, {}, 'public-read')
    end
  end

end
