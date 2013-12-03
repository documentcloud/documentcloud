module DC
  module Store

    # An implementation of an AssetStore.
    module S3Store

      BUCKET_NAME     = Rails.env.production? ? 's3.documentcloud.org' : "dcloud_#{Rails.env}"

      AUTH_PERIOD     = 5.minutes

      IMAGE_EXT       = /\.(gif|png|jpe?g)\Z/

      DEFAULT_ACCESS  = DC::Access::PUBLIC

      # 60 seconds for persistent connections.
      S3_PARAMS       = {:connection_lifetime => 60}

      ACCESS_TO_ACL   = Hash.new('private')
      PUBLIC_LEVELS.each{ |level| ACCESS_TO_ACL[level] = 'public-read' }

      module ClassMethods
        def asset_root
          Rails.env.production? ? "http://s3.documentcloud.org" : "http://s3.amazonaws.com/#{BUCKET_NAME}"
        end
        def web_root
          Thread.current[:ssl] ? "https://s3.amazonaws.com/#{BUCKET_NAME}" : asset_root
        end
      end

      def initialize
        @key, @secret = SECRETS['aws_access_key'], SECRETS['aws_secret_key']
      end

      def read(path)
        bucket.get(path)
      end

      def read_size(path)
        bucket.key(path).size
      end

      def authorized_url(path)
        interface = Thread.current[:ssl] ? secure_s3.interface : s3.interface
        interface.generate_link 'GET', {:url => "#{BUCKET_NAME}/#{CGI::escape(path)}"}, AUTH_PERIOD
      end

      def list(path)
        bucket.keys(:prefix => path).map {|key| key.name }
      end
      
      def save_original(document, file_path, access=DEFAULT_ACCESS)
        save_file(file_path, document.original_file_path, access)
      end
      
      def delete_original(document)
        remove_file(document.original_file_path)
      end

      def save_pdf(document, pdf_path, access=DEFAULT_ACCESS)
        save_file(pdf_path, document.pdf_path, access)
      end

      def save_insert_pdf(document, pdf_path, pdf_name, access=DEFAULT_ACCESS)
        path = File.join(document.path, 'inserts', pdf_name)
        save_file(pdf_path, path, access)
      end

      def delete_insert_pdfs(document)
        path = File.join(document.pdf_path, 'inserts')
        bucket.delete_folder(path)
      end

      def save_full_text(document, access=DEFAULT_ACCESS)
        save_file(document.combined_page_text, document.full_text_path, access, :string => true)
      end

      def save_rdf(document, rdf, access=DEFAULT_ACCESS)
        save_file(rdf, document.rdf_path, DC::Access::PRIVATE, :string => true)
      end

      def save_page_images(document, page_number, images, access=DEFAULT_ACCESS)
        Page::IMAGE_SIZES.keys.each do |size|
          save_file(images[size], document.page_image_path(page_number, size), access) if images[size]
        end
      end

      def delete_page_images(document, page_number)
        Page::IMAGE_SIZES.keys.each do |size|
          remove_file(document.page_image_path(page_number, size))
        end
      end

      def save_page_text(document, page_number, text, access=DEFAULT_ACCESS)
        save_file(text, document.page_text_path(page_number), access, :string => true)
      end

      def delete_page_text(document, page_number)
        remove_file(document.page_text_path(page_number))
      end

      def save_database_backup(name, path)
        bucket.put("backups/#{name}/#{Date.today}.dump", File.open(path))
      end

      # This is going to be *extremely* expensive. We can thread it, but
      # there must be a better way somehow. (running in the background for now)
      def set_access(document, access)
        save_permissions(document.pdf_path, access)
        save_permissions(document.full_text_path, access)
        document.pages.each do |page|
          save_permissions(document.page_text_path(page.page_number), access)
          Page::IMAGE_SIZES.keys.each do |size|
            save_permissions(document.page_image_path(page.page_number, size), access)
          end
        end
        true
      end
      
      def read_original(document)
        read document.original_file_path
      end

      def read_pdf(document)
        read document.pdf_path
      end

      def destroy(document)
        bucket.delete_folder(document.path)
      end
      
      # Duplicate all of the assets from one document over to another.
      def copy_assets(source, destination, access)
        [:copy_pdf, :copy_images, :copy_text].each do |task|
          send(task, source, destination, access)
        end
        true
      end
      
      def copy_text(source, destination, access)
        bucket.copy_key source.full_text_path, destination.full_text_path
        source.pages.each do |page|
          num = page.page_number
          bucket.copy_key source.page_text_path(num), destination.page_text_path(num)
          save_permissions destination.page_text_path(num), access
        end
        true
      end
      
      def copy_images(source, destination, access)
        source.pages.each do |page|
          num = page.page_number
          Page::IMAGE_SIZES.keys.each do |size|
            bucket.copy_key source.page_image_path(num, size), destination.page_image_path(num, size)
            save_permissions destination.page_image_path(num, size), access
          end
        end
        true
      end
      
      def copy_rdf(source, destination, access)
        bucket.copy_key source.rdf_path, destination.rdf_path
        save_permissions destination.rdf_path, access
        true
      end

      def copy_pdf(source, destination, access)
        bucket.copy_key source.pdf_path, destination.pdf_path
        save_permissions destination.pdf_path, access
        true
      end

      private

      def s3
        @s3 ||= create_s3
      end

      def create_s3
        RightAws::S3.new(@key, @secret, S3_PARAMS.merge(:protocol => 'http', :port => 80))
      end

      def secure_s3
        @secure_s3 ||= RightAws::S3.new(@key, @secret, S3_PARAMS.merge(:protocol => 'https', :no_subdomains => true))
      end

      def bucket
        @bucket ||= (s3.bucket(BUCKET_NAME) || s3.bucket(BUCKET_NAME, true))
      end

      def content_type(s3_path)
        Mime::Type.lookup_by_extension(File.extname(s3_path)).to_s
      end

      # Saves a local file to a location on S3, and returns the public URL.
      # Set the expires headers for a year, if the file is an image -- text,
      # HTML and JSON may change.
      def save_file(file, s3_path, access, opts={})
        file = opts[:string] ? file : File.open(file)
        headers = {'content-type' => content_type(s3_path)}
        safe_s3_request do
          bucket.put(s3_path, file, {}, ACCESS_TO_ACL[access], headers)
        end
        bucket.key(s3_path).public_link
      end

      # Remove a file from S3.
      def remove_file(s3_path)
        safe_s3_request do
          bucket.key(s3_path).delete
        end
      end

      # We've been seeing some RequestTimeTooSkewed errors, which is strange
      # because the system clocks are in sync to the millisecond with NTP time.
      # Retry a couple times instead of failing the entire job.
      def safe_s3_request
        attempts = 0
        begin
          attempts += 1
          yield
        rescue RightAws::AwsError, Exception => e
          sleep 10
          @s3 = create_s3
          @bucket = s3.bucket(BUCKET_NAME)
          retry if attempts <= 6
          raise e
        end
      end

      def save_permissions(s3_path, access)
        headers = {'x-amz-acl' => ACCESS_TO_ACL[access], 'content-type' => content_type(s3_path)}
        s3.interface.copy(bucket, s3_path, bucket, s3_path, :replace, headers)
      end

    end

  end
end
