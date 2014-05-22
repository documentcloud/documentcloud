namespace :deploy do

  desc "Deploy only minimal updates to Rails code"
  task :minimal do
    remote ["app:update", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy and migrate the database, then restart CloudCrowd"
  task :full do
    remote ["app:update", "app:jammit", "db:migrate", "app:clearcache:docs", "app:clearcache:search", "app:restart", "app:warm"], app_servers
    remote ["app:update", "crowd:server:restart"], central_servers
    remote ["app:restart_solr"], search_servers
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
  task :viewer => :environment do
    upload_directory_contents 'public/viewer/**/*'
    upload_template( 'app/views/documents/loader.js.erb', 'viewer/loader.js' )
  end

  desc "Deploy the Search/Note Embed to S3"
  {:search_embed => ['search_embed', 'embed'], :note_embed => ['note_embed', 'notes']}.each_pair do |folder, embed|
    task folder => :environment do
      upload_directory_contents "public/#{embed[0]}/**/*"
      upload_template( "app/views/#{embed[0]}/loader.js.erb", "#{embed[1]}/loader.js" )
    end
  end

  # helper methods for tasks that upload to S3
  def upload_bucket
    ::AWS::S3.new( { :secure => false } ).buckets['s3.documentcloud.org']
  end

  def upload_directory_contents( mask )
    bucket = upload_bucket
    Dir[mask].each do |file|
      next if File.directory? file
      mimetype = MIME::Types.type_for(File.extname(file)).first

      puts "uploading #{file} (#{mimetype})"

      object = bucket.objects[ "viewer/#{file.gsub('public/viewer/', '')}" ]
      object.write( Pathname.new(file), {
                      :acl=> :public_read,
                      :content_type=> mimetype ? mimetype.content_type  : nil
                    })

    end
  end

  def upload_template( src_file, s3_destination )
    DC::CONFIG['server_root'] = 's3.documentcloud.org'
    contents = ERB.new(File.read( src_file )).result(binding)
    puts "uploading #{src_file} to #{s3_destination}"

    object = upload_bucket.objects[ s3_destination ]
    object.write( contents, {
                    :acl=> :public_read,
                    :content_type=>'application/javascript'
                  })

  end

end
