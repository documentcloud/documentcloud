module DC
  module Import

    class CalaisFetcher

      # Content limit that Calais sets on number of characters. Minus some
      # safety padding because Calais was still throwing errors. Perhaps they're
      # counting bytes?
      MAX_TEXT_SIZE = 98000

      # Fetch the RDF from OpenCalais, splitting it into chunks small enough
      # for Calais to swallow.
      def fetch_rdf(text)
        text   = text.mb_chars
        chunks = split_text(text)
        chunks.map {|chunk| fetch_rdf_from_calais(chunk) }
      end

      # Divide the text into chunks that pass the size limit.
      # Unused until we have a real RDF merge strategy.
      def split_text(text)
        max = MAX_TEXT_SIZE
        (0..((text.length-1) / max)).map {|i| text[i * max, max]}
      end

      def fetch_rdf_from_calais(text)
        # Calais complains if the content contains HTML tags.
        # So we replace everything that looks like a tag with spaces of the
        # equivalent length before uploading.
        text.gsub!(/<\/?[^>]*>/) {|m| ' ' * m.length }
        retry_calais_errors do
          client = Calais::Client.new(
            :content                        => text,
            :content_type                   => :raw,
            :license_id                     => SECRETS['calais_license'],
            :allow_distribution             => false,
            :allow_search                   => false,
            :submitter                      => "DocumentCloud (#{RAILS_ENV})",
            :omit_outputting_original_text  => true
          )
          Calais::Response.new(client.enlighten)
        end
      end


      private

      def retry_calais_errors
        begin
          yield
        rescue Calais::Error, Curl::Err => e
          Rails.logger.warn e.message
          return nil if e.message == 'Calais continues to expand its list of supported languages, but does not yet support your submitted content.'
          Rails.logger.warn 'waiting 10 seconds'
          sleep 10
          retry
        rescue Exception => e
          puts e.message
          puts e.class
          raise e
        end
      end

    end

  end
end