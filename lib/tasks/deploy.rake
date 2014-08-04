namespace :deploy do
  DEPLOYABLE_ENV = %w(production staging)

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
    unless deployable_environment?
      raise ArgumentError, "Rails.env was (#{Rails.env}) and should be one of #{DEPLOYABLE_ENV.inspect}
(e.g. `rake production deploy:[taskname]`)"
    end
    upload_directory_contents 'public/viewer/**/*'
    upload_template( 'app/views/documents/loader.js.erb', 'viewer/loader.js' )
  end

  desc "Deploy the Search/Note Embed to S3"
  {:search_embed => ['search_embed', 'embed'], :note_embed => ['note_embed', 'notes']}.each_pair do |folder, embed|
    task folder => :environment do
      unless deployable_environment?
        raise ArgumentError, "Rails.env was (#{Rails.env}) and should be one of #{DEPLOYABLE_ENV.inspect}
(e.g. `rake production deploy:[taskname]`)"
      end
      upload_directory_contents "public/#{embed[0]}/**/*"
      upload_template( "app/views/#{embed[0]}/loader.js.erb", "#{embed[1]}/loader.js" )
    end
  end

  # helper methods for tasks that upload to S3
  def bucket
    ::AWS::S3.new( { :secure => false } ).buckets['s3.documentcloud.org']
  end
  
  def upload_directory_contents( glob )
    Dir[glob].each do |file|
      unless File.directory?(file)
        upload_attributes = { :acl => :public_read }

        # attempt to identify the mimetype for this file.
        mimetype = MIME::Types.type_for(File.extname(file)).first
        upload_attributes[:content_type] = mimetype.content_type if mimetype

        puts "uploading #{file} (#{mimetype})"                    
        destination = bucket.objects[ "viewer/#{file.gsub('public/viewer/', '')}" ]
        destination.write( Pathname.new(file), upload_attributes)
      end
    end
  end

  def upload_template( template_path, destination_path )
    contents = render_template(template_path)
    puts "uploading #{template_path} to #{destination_path}"

    destination = bucket.objects[ destination_path ]
    destination.write( contents, { :acl=> :public_read, :content_type=>'application/javascript' })
  end
  
  def render_template(template_path)
    ERB.new(File.read( template_path )).result(binding)    
  end
  
  def deployable_environment?
    DEPLOYABLE_ENV.include? Rails.env
  end
end
