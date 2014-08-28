require 'filemagic'

module DC
  module Store

    module DocumentFileType

      # An exception to raise if the file type doesn't match
      class InvalidFileType < ArgumentError
      end

      # Create single shared of FileMagick since it
      # reads all the definitions on startup
      FILE_MAGIC = FileMagic.new(:mime, :simplified => true)

      # Mime types for files that we are able to process
      VALID_TYPES= [
        'application/pdf',
        'text/plain',
        'text/html',
        'text/rtf',
        'image/jpeg',
        'image/tiff',
        'image/png',
        'image/gif',
        'image/x-ms-bmp',
        'message/rfc822',
        'application/postscript',
        'application/xml',
        'application/msword',
        'application/vnd.ms-excel',
        'application/vnd.ms-powerpoint',
        'application/vnd.oasis.opendocument.text',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document', # these sound crazy but are accurate
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation'
      ]

      # We'd like to support the following formats, but the magic library
      # doesn't currently recognize them and simply returns "application/octet-stream" or "application/zip"
      # WordPerfect .wpd
      # Webarchive  .webarchive
      # XML Paper Specification .xps

      module FileTestMethods
        # Test the mime type of the given file against the list of types we support
        def valid_source_document?(filename)
          VALID_TYPES.include?(FILE_MAGIC.file(filename))
        end
      end

      def self.included(base)
        base.module_eval do
          extend(FileTestMethods)
        end
      end

    end
  end
end
