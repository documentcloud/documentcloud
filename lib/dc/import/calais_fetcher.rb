module DC
  module Import

    class CalaisFetcher

      # Content limit that Calais sets on number of characters. Minus some
      # safety padding because Calais was still throwing errors. Perhaps they're
      # counting bytes?
      MAX_TEXT_SIZE = 95000

      # Fetch the RDF from OpenCalais, splitting it into chunks small enough
      # for Calais to swallow. Run the chunks in parallel.
      def fetch_rdf(text)
        text    = text.mb_chars
        chunks  = split_text(text)
        threads, rdfs = [], []
        begin
          chunks.each_with_index do |chunk, i|
            rdfs[i] = fetch_rdf_from_calais(chunk)
          end
        rescue Exception => e
          LifecycleMailer.deliver_exception_notification(e)
        end
        rdfs
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
        attempts = 0
        begin
          yield
        rescue Calais::Error, Curl::Err::CurlError, Timeout::Error => e
          Rails.logger.warn e.message
          return nil if e.message == 'Calais continues to expand its list of supported languages, but does not yet support your submitted content.'
          Rails.logger.warn 'waiting 10 seconds'
          attempts += 1
          sleep 10
          retry if attempts < 5
        rescue RuntimeError => e
          return nil if e.message == 'content is too large'
          puts e.message
          puts e.class
          raise e
        rescue Exception => e
          puts e.message
          puts e.class
          raise e
        end
      end

    end

  end
end