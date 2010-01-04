module DC
  module Store

    # An implementation of an AssetStore.
    module S3Store

      BUCKET_NAME = "dcloud_#{RAILS_ENV}"

      AUTHORIZATION_PERIOD = 5.minutes

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
        s3.interface.get_link(bucket, path, AUTHORIZATION_PERIOD)
      end

      def save_pdf(document, pdf_path)
        save_file(pdf_path, document.pdf_path)
      end

      def save_thumbnail(document, thumb_path)
        save_file(thumb_path, document.thumbnail_path)
      end

      def save_full_text(document)
        save_file(document.text, document.full_text_path, false)
      end

      def save_page_images(page, images)
        save_file(images[:normal_image], page.image_path('normal'))
        save_file(images[:large_image], page.image_path('large'))
      end

      def save_page_text(page)
        save_file(page.text, page.text_path, false)
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
      def save_file(file, s3_path, path=true)
        file = path ? File.open(file) : file
        bucket.put(s3_path, file, {}, 'public-read')
        bucket.key(s3_path).public_link
      end

    end

  end
end