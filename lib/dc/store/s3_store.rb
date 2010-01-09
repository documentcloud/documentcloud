module DC
  module Store

    # An implementation of an AssetStore.
    module S3Store

      BUCKET_NAME     = "dcloud_#{RAILS_ENV}"

      AUTH_PERIOD     = 5.minutes

      DEFAULT_ACCESS  = DC::Access::PUBLIC

      ACCESS_TO_ACL   = Hash.new('private')
      ACCESS_TO_ACL[DC::Access::PUBLIC] = 'public-read'

      module ClassMethods
        def asset_root
          "http://s3.amazonaws.com/#{BUCKET_NAME}"
        end
        def web_root
          asset_root
        end
      end

      def initialize
        @key, @secret = SECRETS['aws_access_key'], SECRETS['aws_secret_key']
      end

      def authorized_url(path)
        s3.interface.get_link(bucket, path, AUTH_PERIOD)
      end

      def save_pdf(document, pdf_path, access=DEFAULT_ACCESS)
        save_file(pdf_path, document.pdf_path, access)
      end

      def save_thumbnail(document, thumb_path, access=DEFAULT_ACCESS)
        save_file(thumb_path, document.thumbnail_path, access)
      end

      def save_full_text(document, access=DEFAULT_ACCESS)
        save_file(document.text, document.full_text_path, access, :string => true)
      end

      def save_rdf(document, rdf, access=DEFAULT_ACCESS)
        save_file(rdf, document.rdf_path, DC::Access::PRIVATE, :string => true)
      end

      def save_page_images(page, images, access=DEFAULT_ACCESS)
        save_file(images[:normal_image], page.image_path('normal'), access)
        save_file(images[:large_image], page.image_path('large'), access)
      end

      def save_page_text(page, access=DEFAULT_ACCESS)
        save_file(page.text, page.text_path, access, :string => true)
      end

      # This is going to be *extremely* expensive. We can thread it, but
      # there must be a better way somehow. (running in the background for now)
      def set_access(document, access)
        save_permissions(document.pdf_path, access)
        save_permissions(document.full_text_path, access)
        document.pages.each do |page|
          save_permissions(page.text_path, access)
          save_permissions(page.image_path('normal'), access)
          save_permissions(page.image_path('large'), access)
        end
        true
      end

      def read_pdf(document)
        bucket.get(document.pdf_path)
      end

      def destroy(document)
        bucket.delete_folder(document.path)
      end

      # Delete the assets store entirely.
      def delete_database!
        bucket.delete_folder("docs")
      end


      private

      def s3
        @s3 ||= RightAws::S3.new(@key, @secret, :protocol => 'http', :port => 80)
      end

      def bucket
        @bucket ||= (s3.bucket(BUCKET_NAME) || s3.bucket(BUCKET_NAME, true))
      end

      # Saves a local file to a location on S3, and returns the public URL.
      def save_file(file, s3_path, access, opts={})
        file = opts[:string] ? file : File.open(file)
        bucket.put(s3_path, file, {}, ACCESS_TO_ACL[access])
        bucket.key(s3_path).public_link
      end

      def save_permissions(s3_path, access)
        headers = {'x-amz-acl' => ACCESS_TO_ACL[access]}
        s3.interface.copy(bucket, s3_path, bucket, s3_path, :replace, headers)
      end

    end

  end
end