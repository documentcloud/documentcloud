require 'zlib'

namespace :deploy do
  DEPLOYABLE_ENV = %w(production staging)

  desc "Deploy only minimal updates to Rails code"
  task :minimal do
    remote ["app:update", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy and migrate the database, then restart CloudCrowd"
  task :full do
    remote ["app:update", "db:migrate", "crowd:server:restart"], central_servers
    remote ["app:update", "app:jammit", "app:clearcache:docs", "app:clearcache:search", "app:restart", "app:warm"], app_servers
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
    upload_filetree( 'public/viewer/*', '', /^public\//)
    upload_template( 'app/views/documents/loader.js.erb', 'viewer/loader.js' )
  end

  embeds = [{:name => :search_embed, :source_dir => 'search_embed', :destination_dir =>'embed'},
            {:name => :note_embed,   :source_dir => 'note_embed',   :destination_dir =>'notes'}]

  desc "Deploy the Search/Note Embed to S3"
  embeds.each do |embed|
    task embed[:name] => :environment do
      unless deployable_environment?
        raise ArgumentError, "Rails.env was (#{Rails.env}) and should be one of #{DEPLOYABLE_ENV.inspect}
(e.g. `rake production deploy:[taskname]`)"
      end

      # Each loader.js file is the entry point for each embed.
      # It coordinates all of the other javascript and assets.
      # they currently live at /notes/loader.js and /search/loader.js
      upload_template( "app/views/#{embed[:source_dir]}/loader.js.erb", "#{embed[:destination_dir]}/loader.js" )
      # The assets are currently served out of a different directory from each loader.
      # /note_embed/ and /search_embed/ respectively
      local_root = "public/#{embed[:source_dir]}"
      upload_filetree( "#{local_root}/**/*", embed[:source_dir], /^#{local_root}/ )
    end
  end

  # helper methods for tasks that upload to S3
  def bucket; ::AWS::S3.new( { :secure => false } ).buckets[DC::SECRETS['bucket']]; end
  def render_template(template_path); ERB.new(File.read( template_path )).result(binding); end  
  def deployable_environment?; DEPLOYABLE_ENV.include? Rails.env; end

  def upload_filetree( source_pattern, destination_root, source_path_filter=// )
    Dir[source_pattern].each do |file|
      unless File.directory?(file)
        upload_attributes = { :acl => :public_read }

        # attempt to identify the mimetype for this file.
        mimetype = Mime::Type.lookup_by_extension(File.extname(file).remove(/^\./))
        upload_attributes[:content_type] = mimetype.to_s if mimetype

        destination_path = destination_root + file.gsub(source_path_filter, '')
        destination = bucket.objects[destination_path]
        puts "uploading #{file} (#{mimetype}) to #{destination_path}"
        destination.write( Pathname.new(file), upload_attributes)
      end
    end
  end

  def upload_template( template_path, destination_path )
    upload_attributes = { :acl => :public_read }
    contents = render_template(template_path)
    puts "uploading #{template_path} to #{destination_path} and #{destination_path+'.gz'}"

    destination = bucket.objects[ destination_path ]
    destination.write( contents, upload_attributes.merge(:content_type => 'application/javascript') )

    zipped_destination = bucket.objects[ destination_path + '.gz' ]
    zipped_destination.write( gzip_string(contents), upload_attributes.merge(:content_type => Mime::Type.lookup_by_extension('gz').to_s) )
  end
  
  def gzip_string(contents)
    # Create a pipe with an input IO and an output IO
    IO.pipe do |zip_out, zip_in|
      # make sure they're configured to take arbitrary binary data
      zip_in.binmode
      zip_out.binmode
      # attach a gzip compressor as a funnel into the pipe.
      # add the contents to the funnel.
      # and then close off the top of the pipe.
      Zlib::GzipWriter.new(zip_in, Zlib::BEST_COMPRESSION) do |zipper|
        zipper.write(contents)
      end.close
      # retrieve the compressed contents out of the bottom of the pipe.
      zip_out.read
    end
  end
end
