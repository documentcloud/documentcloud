module DC
  module Store

    # An implementation of an AssetStore.
    module AwsS3Store

      BUCKET_NAME     = Rails.env.production? ? 's3.documentcloud.org' : "dcloud_#{Rails.env}"

      AUTH_PERIOD     = 5.minutes

      IMAGE_EXT       = /\.(gif|png|jpe?g)\Z/

      DEFAULT_ACCESS  = DC::Access::PUBLIC

      AWS_REGION      = DC::CONFIG['aws_region']

      # 60 seconds for persistent connections.
      S3_PARAMS       = {:connection_lifetime => 60}

      ACCESS_TO_ACL   = Hash.new(:private)
      DC::Access::PUBLIC_LEVELS.each{ |level| ACCESS_TO_ACL[level] = :public_read }

      module ClassMethods
        def asset_root
          if AWS_REGION == 'us-east-1'
            "https://s3.amazonaws.com/#{BUCKET_NAME}"
          else
            "https://s3-#{AWS_REGION}.amazonaws.com/#{BUCKET_NAME}"
          end
        end
        def web_root
          asset_root
        end
      end
      
      def initialize
        @key, @secret = DC::SECRETS['aws_access_key'], DC::SECRETS['aws_secret_key']
      end
      
      def read(path)
        bucket.objects[path].read
      end
      
      def read_size(path)
        bucket.objects[path].content_length
      end
      
      def authorized_url(path, opts={})
        options = {
          secure: Thread.current[:ssl],
          expires: AUTH_PERIOD
        }
        # We only want to interject a content type if it's specified; otherwise,
        # let S3 serve whatever content type the file was stored with.
        options[:response_content_type] = opts[:content_type] if opts[:content_type]
        bucket.objects[path].url_for(:read, options).to_s
      end
      
      def list(path)
        bucket.objects.with_prefix(path).map {|obj| obj.key }
      end
      
      def save_original(document, file_path, access=DEFAULT_ACCESS)
        save_file_from_path(file_path, document.original_file_path, access)
      end
      
      def delete_original(document)
        remove_file(document.original_file_path)
      end
      
      def save_pdf(document, pdf_path, access=DEFAULT_ACCESS)
        save_file_from_path(pdf_path, document.pdf_path, access)
      end
      
      def save_insert_pdf(document, pdf_path, pdf_name, access=DEFAULT_ACCESS)
        path = File.join(document.path, 'inserts', pdf_name)
        save_file_from_path(pdf_path, path, access)
      end
      
      def delete_insert_pdfs(document)
        path = File.join(document.pdf_path, 'inserts')
        bucket.objects.with_prefix(path).delete_all
      end
      
      def save_full_text(document, access=DEFAULT_ACCESS)
        save_file(document.combined_page_text, document.full_text_path, access)
      end
      
      def save_rdf(document, rdf, access=DEFAULT_ACCESS)
        save_file(rdf, document.rdf_path, DC::Access::PRIVATE)
      end
      
      def save_page_images(document, page_number, images, access=DEFAULT_ACCESS)
        Page::IMAGE_SIZES.keys.each do |size|
          save_file_from_path(images[size], document.page_image_path(page_number, size), access) if images[size]
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
      
      def save_tabula_page(document, page_number, data, access=DEFAULT_ACCESS)
        tabula_page_path = document.page_text_path(page_number).sub(/txt$/, 'csv')
        save_file(data, tabula_page_path, access, :string => true)
      end
      
      def delete_tabula_page(document, page_number)
        tabula_page_path = document.page_text_path(page_number).sub(/txt$/, 'csv')
        remove_file(tabula_page_path)
      end
      
      def save_backup(src, dest)
        bucket.objects["backups/#{dest}"].write(File.open(src))
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
        bucket.objects.with_prefix(File.join(document.path, '/')).delete_all
      end
      
      # Duplicate all of the assets from one document over to another.
      def copy_assets(source, destination, access)
        [:copy_pdf, :copy_images, :copy_text].each do |task|
          send(task, source, destination, access)
        end
        true
      end
      
      def copy_text(source, destination, access)
        options = {:acl => ACCESS_TO_ACL[access], :content_type => content_type(destination.full_text_path)}
        bucket.objects[source.full_text_path].copy_to(destination.full_text_path, options)
        source.pages.each do |page|
          num = page.page_number
          source_object = bucket.objects[source.page_text_path(num)]
          source_object.copy_to(destination.page_text_path(num), options)
        end
        true
      end
      
      def copy_images(source, destination, access)
        source.pages.each do |page|
          num = page.page_number
          Page::IMAGE_SIZES.keys.each do |size|
            source_object = bucket.objects[source.page_image_path(num, size)]
            options = {:acl => ACCESS_TO_ACL[access], :content_type => content_type(source.page_text_path(num))}
            source_object.copy_to(destination.page_image_path(num, size), options)
          end
        end
        true
      end
      
      def copy_rdf(source, destination, access)
        source_object = bucket.objects[source.rdf_path]
        options = {:acl => ACCESS_TO_ACL[access], :content_type => content_type(source.rdf_path)}
        source_object.copy_to(destination.rdf_path, options)
        true
      end
      
      def copy_pdf(source, destination, access)
        source_object = bucket.objects[source.pdf_path]
        options = {:acl => ACCESS_TO_ACL[access], :content_type => content_type(source.pdf_path)}
        source_object.copy_to(destination.pdf_path, options)
        true
      end

      # This is a potentially expensive (as in $$) method since S3 charges by the request
      # returns an array of paths that should exist in the S3 bucket but do not
      def validate_assets(document)
        invalid = []
        1.upto(document.page_count) do |pg|
          text_path  = document.page_text_path(pg)
          invalid << text_path unless bucket.objects[text_path].exists?
          Page::IMAGE_SIZES.keys.each do |size|
            image_path = document.page_image_path(pg, size)
            invalid << image_path unless bucket.objects[image_path].exists?
          end
        end
        invalid
      end
      
      private

      def s3
        @s3 ||= create_s3
      end

      def create_s3
        ::AWS::S3.new(:access_key_id => @key, :secret_access_key => @secret)
      end

      def secure_s3
        @secure_s3 ||= ::AWS::S3.new(:access_key_id => @key, :secret_access_key => @secret, :secure => true)
      end
      
      def cloudfront
        @cloudfront ||= create_cloudfront
      end
      
      def create_cloudfront
        ::AWS::CloudFront.new :access_key_id => @key, :secret_access_key => @secret
      end
      
      def cloudfront_invalidation_list
        cloudfront.client.list_invalidations(:distribution_id=>DC::SECRETS['cloudfront_distribution_id'])
      end
      
      def cloudfront_invalidation_quantity
        cloudfront_invalidation_list[:quantity]
      end

      def bucket
        @bucket ||= (s3.buckets[BUCKET_NAME].exists? ? s3.buckets[BUCKET_NAME] : s3.buckets.create(BUCKET_NAME))
      end

      def content_type(s3_path)
        ext = File.extname(s3_path).remove(/^\./)
        case ext
          when 'txt'
            'text/plain; charset=utf-8'
          else
            Mime::Type.lookup_by_extension(ext).to_s
        end
      end

      # Saves a local file to a location on S3, and returns the public URL.
      # Set the expires headers for a year, if the file is an image -- text,
      # HTML and JSON may change.
      def save_file(contents, s3_path, access, opts={})
        destination = bucket.objects[s3_path]
        options = opts.merge(:acl => ACCESS_TO_ACL[access], :content_type => content_type(s3_path))
        destination.write(contents, options)
        destination.public_url({ :secure => Thread.current[:ssl] }).to_s
      end
      
      def save_file_from_path(file_path, s3_path, access, opts ={})
        save_file(File.open(file_path), s3_path, access, opts )
      end

      # Remove a file from S3.
      def remove_file(s3_path)
        bucket.objects[s3_path].delete
      end

      def save_permissions(s3_path, access)
        bucket.objects[s3_path].copy_to(s3_path, :acl => ACCESS_TO_ACL[access], :content_type => content_type(s3_path))
      end

    end
  end
end
