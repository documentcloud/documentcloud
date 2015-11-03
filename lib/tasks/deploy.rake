require 'zlib'

namespace :deploy do
  DEPLOYABLE_ENV = %w(production staging)

  desc "Deploy Rails app"
  task :minimal do
    remote ["app:update", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy Rails app and clear the JSON object cache"
  task :rails do
    remote ["app:update", "app:clearcache:docs", "app:clearcache:search", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy Rails app, update and compile static assets, and clear the JSON object cache"
  task :app do
    remote ["app:update", "app:bower", "app:jammit", "app:clearcache:docs", "app:clearcache:search", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy and migrate the database, then restart CloudCrowd"
  task :full do
    invoke "deploy:cluster"
    invoke "deploy:app"
    # invoke "deploy:search" # Solr is behaving badly, deploy manually for now
    invoke "deploy:workers"
  end

  desc "Deploy Rails app to CloudCrowd server, migrate database, and restart CloudCrowd"
  task :cluster do
    remote ["app:update", "db:migrate", "crowd:server:restart"], central_servers
  end

  desc "Deploy Rails app to workers and restart CloudCrowd nodes"
  task :workers do
    remote ["app:update", "crowd:node:restart"], worker_servers
  end

  desc "Deploy Rails app to search server and restart Solr"
  task :search do
    remote ["app:update", "app:restart_solr"], search_servers
  end

  # TODO: Consolidate these using a loop like in the old version. This is just
  #       an explicit first pass to draw attention to the similarities/diffs.
  namespace :embed do

    # Deploy document viewer (https://github.com/documentcloud/document-viewer)
    task :document => :environment do
      unless deployable_environment?
        raise ArgumentError, "Rails.env was (#{Rails.env}) and should be one of #{DEPLOYABLE_ENV.inspect} (e.g. `rake production deploy:[taskname]`)"
      end

      # Upload loader (entry point)
      upload_template( 'app/views/documents/embed_loader.js.erb', 'viewer/loader.js' )
      # Upload assets: scripts, styles, and images
      local_root = "public/viewer"
      upload_filetree( "#{local_root}/**/*", "viewer", /^#{local_root}/ )
    end

    # Deploy page embed (https://github.com/documentcloud/documentcloud-pages)
    task :page => :environment do
      unless deployable_environment?
        raise ArgumentError, "Rails.env was (#{Rails.env}) and should be one of #{DEPLOYABLE_ENV.inspect} (e.g. `rake production deploy:[taskname]`)"
      end

      # Upload loader (entry point)
      upload_template( "public/embeds/page/enhance.js", "embed/loader/enhance.js" )
      # Upload assets: scripts, styles, and images
      local_root = "public/embeds/page"
      upload_filetree( "#{local_root}/**/*", "embed/page", /^#{local_root}/ )
    end

    # Deploy note embed (https://github.com/documentcloud/documentcloud-notes)
    task :note => :environment do
      unless deployable_environment?
        raise ArgumentError, "Rails.env was (#{Rails.env}) and should be one of #{DEPLOYABLE_ENV.inspect} (e.g. `rake production deploy:[taskname]`)"
      end

      # Upload loader (entry point)
      upload_template( "app/views/annotations/embed_loader.js.erb", "notes/loader.js" )
      # Upload assets: scripts, styles, and images
      local_root = "public/note_embed"
      upload_filetree( "#{local_root}/**/*", "note_embed", /^#{local_root}/ )
    end

    # Deploy search embed (document list)
    task :search => :environment do
      unless deployable_environment?
        raise ArgumentError, "Rails.env was (#{Rails.env}) and should be one of #{DEPLOYABLE_ENV.inspect} (e.g. `rake production deploy:[taskname]`)"
      end

      # Upload loader (entry point)
      upload_template( "app/views/search/embed_loader.js.erb", "embed/loader.js" )
      # Upload assets: scripts, styles, and images
      local_root = "public/search_embed"
      upload_filetree( "#{local_root}/**/*", "search_embed", /^#{local_root}/ )
    end

  end

  task :viewer do
    puts "DEPRECATED. Use `deploy:embed:document` instead."
  end
  task :note_embed do
    puts "DEPRECATED. Use `deploy:embed:note` instead."
  end
  task :search_embed do
    puts "DEPRECATED. Use `deploy:embed:search` instead."
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
        puts "Uploading #{file} (#{mimetype}) to #{destination_path}"
        destination.write( Pathname.new(file), upload_attributes)
      end
    end
  end

  def upload_template( template_path, destination_path )
    upload_attributes = { :acl => :public_read }
    contents = render_template(template_path)
    puts "Uploading #{template_path} to #{destination_path} and #{destination_path + '.gz'}"

    destination = bucket.objects[ destination_path ]
    destination.write( contents, upload_attributes.merge(:content_type => 'application/javascript') )

    # TODO: Configure S3/CloudFront to actually serve these
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
