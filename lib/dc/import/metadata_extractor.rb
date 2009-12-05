module DC
  module Import

    # The MetadataExtractor takes in a raw RDF file from OpenCalais, pulls out
    # all of the whitelisted metadata we're interested in, and attaches them
    # to the document.
    class MetadataExtractor

      OVER_CALAIS_QPS = '<h1>403 Developer Over Qps</h1>'

      # Public API: Pass in a document, either with full_text or rdf already
      # attached.
      def extract_metadata(document)
        document.metadata = []
        response = fetch_entities(document)
        extract_full_text(document, response)
        extract_standard_metadata(document, response)
        extract_categories(document, response)
        extract_entities(document, response)
      end


      private

      # If the document has full_text, we can go fetch the RDF from Calais.
      def fetch_entities(document)
        begin
          rdf = DC::Import::CalaisFetcher.new.fetch_rdf(document.text)
          return Calais::Response.new(rdf)
        rescue Calais::Error, Curl::Err => e
          Rails.logger.warn e.message
          return nil if e.message == 'Calais continues to expand its list of supported languages, but does not yet support your submitted content.'
          Rails.logger.warn 'waiting 10 seconds'
          sleep 10
          retry
        end
      end

      # Pull out all of the standard, top-level metadata, and add it to our
      # document if it hasn't already been set.
      def extract_standard_metadata(document, calais)
        document.title ||= calais.doc_title
        document.language = 'en' # TODO: Convert calais.language into an ISO language code.
        document.publication_date ||= calais.doc_date
        document.calais_id = calais.request_id
      end

      # Extract the categories that the Document falls under.
      def extract_categories(document, calais)
        document.metadata += calais.categories.map do |cat|
          Metadatum.new(
            :value      => cat.name.underscore,
            :kind       => 'category',
            :relevance  => cat.score || Metadatum::DEFAULT_RELEVANCE,
            :document   => document
          )
        end
      end

      # Extract the entities that Calais discovers in the document, along with
      # the positions where they occur.
      def extract_entities(document, calais)
        extracted = []
        calais.entities.each do |entity|
          next unless Metadatum.acceptable_kind? entity.type
          occurrences = entity.instances.map {|i| Occurrence.new(i.offset, i.length) }
          extracted << Metadatum.new(
            :value        => entity.attributes['name'],
            :kind         => entity.type.underscore,
            :relevance    => entity.relevance,
            :document     => document,
            :occurrences  => Occurrence.to_csv(occurrences),
            :calais_id    => entity.calais_hash.value
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
        document.summary = full_text[0...255]
        document.full_text = FullText.new(:text => full_text, :document => document)
        document.pages = [Page.new(:text => full_text, :document => document, :page_number => 1)]
      end

    end

  end
end