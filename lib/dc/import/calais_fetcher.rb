module DC
  module Import
    
    class CalaisFetcher
      
      # Content limit that Calais sets on characters.
      MAX_TEXT_SIZE = 100000
      
      # If the document has full_text, we can go fetch the RDF from Calais.
      def fetch_rdf(text)
        # Calais complains if the content contains HTML tags...
        text = HTML::FullSanitizer.new.sanitize(text)
        client = Calais::Client.new(
          :content                        => text,
          :content_type                   => :text,
          :license_id                     => SECRETS['calais_license'],
          :allow_distribution             => false,
          :allow_search                   => false,
          :submitter                      => "DocumentCloud (#{RAILS_ENV})",
          :omit_outputting_original_text  => true
        )
        client.enlighten
      end
      
    end
    
  end
end