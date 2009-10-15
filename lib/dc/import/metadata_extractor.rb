gem 'documentcloud-calais'
require 'calais'

module DC
  module Import
    
    # The MetadataExtractor takes in a raw RDF file from OpenCalais, pulls out
    # all of the whitelisted metadata we're interested in, and attaches them
    # to the document.
    class MetadataExtractor
      
      OVER_CALAIS_QPS = '<h1>403 Developer Over Qps</h1>'
      
      # Public API: Pass in a document, either with full_text or rdf already 
      # attached.
      def extract_metadata(document, response=nil)
        return unless ensure_rdf(document)
        begin
          response ||= Calais::Response.new(document.rdf)
        rescue Calais::Error => e
          RAILS_DEFAULT_LOGGER.warn(e.message)
          return
        end      
        document.metadata = []
        extract_full_text(document, response)
        extract_summary(document)
        extract_standard_metadata(document, response)
        extract_categories(document, response)
        extract_entities(document, response)
      end
      
      
      private
      
      # If the document has full_text, we can go fetch the RDF from Calais.
      def ensure_rdf(document)
        if document.rdf
          if document.rdf == OVER_CALAIS_QPS
            RAILS_DEFAULT_LOGGER.warn("Document ##{document.id} went over the Calais developer limit.")
            return false
          end
          return true
        end
        raise DC::DocumentNotValid.new('In order for the MetadataExtractor to process it, a document must have either rdf or full_text.') if !document.full_text
        document.rdf = CalaisFetcher.new.fetch_rdf(document.full_text)
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
          Metadatum.new(cat.name.underscore, 'category', cat.score, :document => document)
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
            {
              :document    => document,
              :occurrences => entity.instances.map {|i| Occurrence.new(i.offset, i.length) },
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
        xml = Nokogiri::XML.parse(document.rdf)
        wrapped = Nokogiri::XML.parse(xml.root.search('//c:document').first.content)
        full_text = wrapped.root.search('//body').first.content.strip
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