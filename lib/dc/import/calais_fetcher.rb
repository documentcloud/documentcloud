require 'curb'

module DC
  module Import

    class CalaisFetcher

      # Content limit that Calais sets on number of characters. Minus some
      # safety padding because Calais was still throwing errors. Perhaps they're
      # counting bytes?
      MAX_TEXT_SIZE = 95000
      API_LIMIT     = DC::SECRETS['calais_api_limit']

      # Fetch the RDF from OpenCalais, splitting it into chunks small enough
      # for Calais to swallow. Run the chunks in parallel.
      def fetch_rdf(text)
        rdfs    = []
        begin
          rdfs = split_text(text).map do |chunk|
            fetch_rdf_from_calais(chunk)
          end
        rescue Exception => e
          LifecycleMailer.exception_notification(e).deliver_now
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
          # Increment the count of our API calls
          current_value = AppConstant.value("calais_calls_made").to_i
          # If we are over the max calls allowed, blacklist the action
          if current_value < API_LIMIT
            client = OpenCalais::Client.new(:api_key=>DC::SECRETS['calais_license'])
            analyzed_text = client.analyze(text, :exact => false)
            AppConstant.transaction do
              current_value = AppConstant.value("calais_calls_made").to_i
              AppConstant.replace("calais_calls_made", current_value + 1)
            end
            return analyzed_text
          else
            RestClient.post DC::CONFIG['cloud_crowd_server'] + '/blacklist', {action: "reprocess_entities"}
            false
          end
        end
      end

      private

      def retry_calais_errors
        attempts = 0
        begin
          yield
        rescue Faraday::Error, Timeout::Error => e
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
