module DC
  module Store

    # Contains common functionality of sub-document models.
    module DocumentFileType

      def valid_source_document?(path)
        # Needs escaping or use magic gem
        mime = `file --brief --mime-type #{path}`.chomp
        mime !~ /audio/
      end
    end
  end
end
