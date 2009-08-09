module DC
  module Ingest
    
    # The CalaisExtractor takes in a raw RDF file from OpenCalais, pulls out
    # all of the whitelisted metadata we're interested in, and attaches them
    # to the document.
    class CalaisExtractor
      
      def initialize
        
      end
      
      # Public API: Pass in a document, sans-metadata, but with RDF attached
      # as a raw XML string.
      def extract_metadata(document)
        calais = Calais::Response.new(document.rdf)
        extract_standard_metadata(document, calais)
        extract_categories(document, calais)
        extract_entities(document, calais)
      end
      
      
      private
      
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
          Metadatum.new(cat.name.underscore, 'category', cat.score)
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
            entity.instances.map {|i| Instance.new(i.offset, i.length) }
          )
        end
        document.metadata += extracted
      end
      
    end
    
  end
end