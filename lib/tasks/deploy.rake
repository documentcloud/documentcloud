namespace :deploy do
  DEPLOYABLE_ENV = %w(production staging)

  desc "Deploy Rails app"
  task :minimal do
    remote ["app:update", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy Rails app and clear the JSON object cache"
  task :rails do
    remote ["app:update", "app:clearcache:documents", "app:clearcache:search", "app:restart", "app:warm"], app_servers
  end

  desc "Deploy Rails app, update and compile static assets, and clear the JSON object cache"
  task :app do
    remote ["app:update", "app:bower", "app:jammit", "app:clearcache:documents", "app:clearcache:search", "app:restart", "app:warm"], app_servers
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

  namespace :embed do

    embeds = [
      { :name        => :viewer,
        :embed_name  => :document,
        :loader_dest => 'viewer/loader.js',
        :asset_dir   => 'viewer'
      },
      { :name        => :page,
        :loader_dest => 'embed/loader/enhance.js',
        :asset_dir   => 'embed/page'
      },
      { :name        => :note,
        :loader_dest => 'notes/loader.js',
        :asset_dir   => 'note_embed'
      },
      { :name        => :search,
        :loader_dest => 'embed/loader.js',
        :asset_dir   => 'search_embed'
      }
    ]

    embeds.each do |embed|
      task embed[:name] => :environment do
        if deployable_environment?
          # Upload assets (scripts, styles, and images)
          upload_filetree("public/#{embed[:asset_dir]}/**/*", embed[:asset_dir], /^public\/#{embed[:asset_dir]}/)

          # Upload loader (entry point)
          upload_loader(embed)
        else
          # Ignore the file tree, but generate and dump loader for inspection
          puts generate_loader(embed)
        end

      end
    end

    task :all => :environment do
      embeds.each do |embed|
        invoke "deploy:embed:#{embed[:name]}"
      end
    end

  end

  # Notices for old task names

  task :viewer do       puts "REMOVED: Use `deploy:embed:document` instead." end
  task :note_embed do   puts "REMOVED: Use `deploy:embed:note` instead." end
  task :search_embed do puts "REMOVED: Use `deploy:embed:search` instead." end

  # Helpers

  def upload_filetree( source_pattern, destination_root, source_path_filter=// )
    Dir[source_pattern].each do |file|
      unless File.directory?(file) || compressed?(file)
        upload_attributes = { :acl => :public_read }

        # Attempt to identify the MIME type for this file
        file_extension = File.extname(file).remove(/^\./)
        mime_type      = Mime::Type.lookup_by_extension(file_extension)
        upload_attributes[:content_type] = mime_type.to_s if mime_type

        if compressable?(file)
          # Compress `foo.css` and upload it as `foo.css`
          file_contents = gzip_string(File.read(file))
          upload_attributes[:content_encoding] = 'gzip'
          message_suffix = " (compressed)"

          # NB: We would *like* to re-use Jammit's precompressed `.gz` file if 
          # it exists, but they seem to be broken. At least, browsers think so.
          # But in case that's ever fixed, here's the logic we'd *like* to have.
          # 
          # if File.exists?("#{file}.gz")
          #   file_contents = File.read("#{file}.gz")
          # else
          #   file_contents = gzip_string(File.read(file))
          # end
        else
          # File isn't compressable; upload as-is
          file_contents = file
        end

        destination_path = destination_root + file.gsub(source_path_filter, '')
        puts "Uploading #{file} (#{mime_type}) to #{destination_path}#{message_suffix}"
        destination = bucket.objects[destination_path]
        destination.write(file_contents, upload_attributes)
      end
    end
  end

  def upload_loader(embed)
    upload_attributes = {
      :acl              => :public_read,
      :content_type     => 'application/javascript',
      :content_encoding => 'gzip'
    }

    file_contents = gzip_string(generate_loader(embed))
    puts "Uploading #{embed[:loader_dest]} (compressed)"
    destination = bucket.objects[embed[:loader_dest]]
    destination.write(file_contents, upload_attributes)
  end
  
  def generate_loader(embed)
    # For historical reasons, we call the document embed "viewer" in some 
    # contexts but refer to it more sensibly as "document" in the DC::Embed 
    # context. If we've defined a separate embed name, use it.
    embed_name = embed[:embed_name] ? embed[:embed_name] : embed[:name]
    DC::Embed.embed_klass(embed_name).static_loader
  end

  # NB: `:secure => true` may be a placebo, as I can't find documentation about     what it does and flipping it doesn't seem to affect the bucket's `url`.
  def bucket; ::AWS::S3.new({ :secure => true }).buckets[DC::SECRETS['bucket']]; end
  def deployable_environment?; DEPLOYABLE_ENV.include?(Rails.env); end
  def compressed?(file); File.extname(file).remove(/^\./) == 'gz'; end
  def compressable?(file); ['css', 'js'].include?(File.extname(file).remove(/^\./)); end
  def gzip_string(contents); ActiveSupport::Gzip.compress(contents, Zlib::BEST_COMPRESSION); end
end
