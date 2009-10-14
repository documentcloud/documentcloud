gem 'documentcloud-calais'
require 'calais'

module DC
  module Import
    
    class CalaisFetcher
      
      # Content limit that Calais sets on number of characters.
      MAX_TEXT_SIZE = 99500
      
      # If the document has full_text, we can go fetch the RDF from Calais.
      # If the document is too long for Calais, we just fetch the first chunk.
      # We can't split it into chunks and then re-merge it, because then our
      # Metadata positions and relevances are all off.
      def fetch_rdf(text)
        fetch_rdf_from_calais(text[0..MAX_TEXT_SIZE])
      end
      
      private
      
      # Divide the text into chunks that pass the size limit.
      # Unused until we have a real RDF merge strategy.
      def split_text(text)
        max = MAX_TEXT_SIZE
        (0..((text.length-1) / max)).map {|i| text[i * max, max]}
      end
      
      def fetch_rdf_from_calais(text)
        # Calais complains if the content contains HTML tags...
        # TODO: Fix this in some other way.
        text.gsub!(/<\/?[^>]*>/, "")
        client = Calais::Client.new(
          :content                        => text,
          :content_type                   => :text,
          :license_id                     => SECRETS['calais_license'],
          :allow_distribution             => false,
          :allow_search                   => false,
          :submitter                      => "DocumentCloud (development)",
          :omit_outputting_original_text  => true
        )
        client.enlighten
      end
      
    end
    
  end
end