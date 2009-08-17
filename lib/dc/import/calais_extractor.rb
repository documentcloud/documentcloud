module DC
  module Import
    
    # The CalaisExtractor takes in a raw RDF file from OpenCalais, pulls out
    # all of the whitelisted metadata we're interested in, and attaches them
    # to the document.
    class CalaisExtractor
      
      # Content limit that Calais sets on characters.
      MAX_TEXT_SIZE = 100000
      
      # Public API: Pass in a document, either with full_text or rdf already 
      # attached.
      def extract_metadata(document)
        ensure_rdf(document)
        calais = Calais::Response.new(document.rdf)        
        document.metadata = []
        extract_full_text(document, calais)
        extract_summary(document)
        extract_standard_metadata(document, calais)
        extract_categories(document, calais)
        extract_entities(document, calais)
      end
      
      
      private
      
      # If the document has full_text, we can go fetch the RDF from Calais.
      def ensure_rdf(document)
        return if document.rdf
        raise DC::DocumentNotValid.new('In order for the CalaisExtractor to process it, a document must have either rdf or full_text.') if !document.full_text
        client = Calais::Client.new(
          :content                        => document.full_text,
          :content_type                   => :text,
          :license_id                     => SECRETS['calais'],
          :allow_distribution             => false,
          :allow_search                   => false,
          :submitter                      => "DocumentCloud (#{RAILS_ENV})",
          :omit_outputting_original_text  => true
        )
        document.rdf = client.enlighten
      end
      
      # Pull out all of the standard, top-level metadata, and add it to our
      # document if it hasn't already been set.
      def extract_standard_metadata(document, calais)
        document.title ||= calais.doc_title
        document.language ||= calais.language || 'English'
        document.date ||= calais.doc_date
        document.calais_signature = calais.signature
        document.calais_request_id = calais.request_id
      end
      
      # Extract the categories that the Document falls under.
      def extract_categories(document, calais)
        document.metadata += calais.categories.map do |cat|
          Metadatum.new(cat.name.underscore, 'category', cat.score, document.id)
        end
      end
      
      # Extract the entities that Calais discovers in the document, along with
      # the positions where they occur. 
      def extract_entities(document, calais)
        extracted = []
        calais.entities.each do |entity|
          next unless Metadatum.acceptable_type? entity.type
          extracted << Metadatum.new(
            entity.attributes['name'], 
            entity.type.underscore,
            entity.relevance,
            document.id,
            {
              :ocurrences => entity.instances.map {|i| Occurrence.new(i.offset, i.length) },
              :calais_hash => entity.calais_hash.value
            }
          )
        end
        document.metadata += extracted
      end
      
      # Hopefully we'll never need to use this method, but if you pass in 
      # a document that doesn't have any full_text, we can take it out of
      # the Calais RDF response.
      def extract_full_text(document, calais)
        return if document.full_text
        xml = XML::Parser.string(document.rdf).parse
        wrapped = XML::Parser.string(xml.root.find('//c:document').first.content).parse
        full_text = wrapped.root.find('//body').first.content.strip
        full_text.gsub!(/(\[\[|\]\]|\{\{|\}\})/, '')
        document.full_text = full_text
      end
      
      # Pull out the executive summary.
      def extract_summary(document)
        document.summary = document.full_text[0...255]
      end
      
    end
    
  end
end