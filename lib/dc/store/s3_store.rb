module DC
  module Store

    # An implementation of an AssetStore.
    module S3Store

      BUCKET_NAME     = Rails.env.production? ? 's3.documentcloud.org' : "dcloud_#{Rails.env}"

      AUTH_PERIOD     = 5.minutes

      IMAGE_EXT       = /\.(gif|png|jpe?g)\Z/

      DEFAULT_ACCESS  = DC::Access::PUBLIC

      ACCESS_TO_ACL   = Hash.new('private')
      ACCESS_TO_ACL[DC::Access::PUBLIC] = 'public-read'

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

      def authorized_url(path)
        interface = Thread.current[:ssl] ? secure_s3.interface : s3.interface
        interface.generate_link 'GET', {:url => "#{BUCKET_NAME}/#{CGI::escape(path)}"}, AUTH_PERIOD
      end

      def list(path)
        bucket.keys(:prefix => path).map {|key| key.name }
      end

      def save_pdf(document, pdf_path, access=DEFAULT_ACCESS)
        save_file(pdf_path, document.pdf_path, access)
      end

      def save_full_text(document, access=DEFAULT_ACCESS)
        save_file(document.text, document.full_text_path, access, :string => true)
      end

      def save_rdf(document, rdf, access=DEFAULT_ACCESS)
        save_file(rdf, document.rdf_path, DC::Access::PRIVATE, :string => true)
      end

      def save_page_images(document, page_number, images, access=DEFAULT_ACCESS)
        Page::IMAGE_SIZES.keys.each do |size|
          save_file(images[size], document.page_image_path(page_number, size), access) if images[size]
        end
      end

      def save_page_text(document, page_number, text, access=DEFAULT_ACCESS)
        save_file(text, document.page_text_path(page_number), access, :string => true)
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

      def read_pdf(document)
        read document.pdf_path
      end

      def destroy(document)
        bucket.delete_folder(document.path)
      end


      private

      def s3
        @s3 ||= create_s3
      end

      def create_s3
        RightAws::S3.new(@key, @secret, :protocol => 'http', :port => 80, :multi_thread => true)
      end

      def secure_s3
        @secure_s3 ||= RightAws::S3.new(@key, @secret, :protocol => 'https', :no_subdomains => true, :multi_thread => true)
      end

      def bucket
        @bucket ||= (s3.bucket(BUCKET_NAME) || s3.bucket(BUCKET_NAME, true))
      end

      # Saves a local file to a location on S3, and returns the public URL.
      # Set the expires headers for a year, if the file is an image -- text,
      # HTML and JSON may change.
      #
      # We've been seeing some RequestTimeTooSkewed errors, which is strange
      # because the system clocks are in sync to the millisecond with NTP time.
      # Retry a couple times instead of failing the entire job.
      def save_file(file, s3_path, access, opts={})
        file = opts[:string] ? file : File.open(file)
        headers = s3_path.match(IMAGE_EXT) ? {'Expires' => 1.year.from_now.httpdate} : {}
        attempts = 0
        begin
          attempts += 1
          bucket.put(s3_path, file, {}, ACCESS_TO_ACL[access], headers)
        rescue RightAws::AwsError, Exception => e
          sleep 10
          @s3 = create_s3
          @bucket = s3.bucket(BUCKET_NAME)
          retry if attempts <= 6
          raise e
        end
        bucket.key(s3_path).public_link
      end

      def save_permissions(s3_path, access)
        headers = {
          'x-amz-acl' => ACCESS_TO_ACL[access],
          'Expires' => 1.year.from_now.httpdate
        }
        s3.interface.copy(bucket, s3_path, bucket, s3_path, :replace, headers)
      end

    end

  end
end