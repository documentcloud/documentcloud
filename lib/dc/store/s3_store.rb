module DC
  module Store
    
    # An implementation of an AssetStore.
    module S3Store
      
      WEB_URL     = /\Ahttps?:\/\//
      BUCKET_NAME = "dcloud_#{RAILS_ENV}"
      
      def initialize
        @key, @secret = SECRETS['aws_access_key'], SECRETS['aws_secret_key']
      end
      
      def save(document)
        save_pdf(document)
        save_images(document)
        save_full_text(document)
      end
      
      def full_text_for(document)
        bucket.get(prefix(document, 'full_text.txt'))
      end
      
      def destroy(document)
        bucket.delete_folder("docs/#{document.id}")
      end
      
      # Delete the assets store entirely.
      def delete_database!
        bucket.delete_folder("docs")
      end
      
      
      private 
      
      def bucket
        @s3 ||= RightAws::S3.new(@key, @secret, :protocol => 'http', :port => 80)
        @bucket ||= (@s3.bucket(BUCKET_NAME) || @s3.bucket(BUCKET_NAME, true))
      end
      
      def prefix(document, s3_name)
        File.join('docs', document.id, s3_name)
      end
      
      # Saves a local file to a location on S3, and returns the public URL.
      def save_file(file, s3_path, path=true)
        return file if path && file.match(WEB_URL)
        file = path ? File.open(file) : file
        bucket.put(s3_path, file, {}, 'public-read')
        bucket.key(s3_path).public_link
      end
      
      def save_pdf(document)
        local = document.pdf
        remote = prefix(document, File.basename(local))
        document.pdf = save_file(local, remote)
      end
      
      def save_images(document)
        document.small_thumbnail = save_file(document.small_thumbnail, prefix(document, "thumbnail_small.jpg"))
        document.thumbnail = save_file(document.thumbnail, prefix(document, "thumbnail.jpg"))
      end
      
      def save_full_text(document)
        save_file(document.full_text, prefix(document, "full_text.txt"), false)
      end
      
    end
    
  end
end