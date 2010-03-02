module DC
  module Import

    # The MetadataExtractor takes in a raw RDF file from OpenCalais, pulls out
    # all of the whitelisted metadata we're interested in, and attaches them
    # to the document.
    class MetadataExtractor

      OVER_CALAIS_QPS = '<h1>403 Developer Over Qps</h1>'

      MAX_TEXT_SIZE = CalaisFetcher::MAX_TEXT_SIZE

      # Public API: Pass in a document, either with full_text or rdf already
      # attached.
      def extract_metadata(document)
        document.metadata = []
        chunks = CalaisFetcher.new.fetch_rdf(document.text)
        chunks.each_with_index do |chunk, i|
          extract_standard_metadata(document, chunk, i) if i == 0
          extract_entities(document, chunk, i)
        end
        document.save
      end


      private

      # Pull out all of the standard, top-level metadata, and add it to our
      # document if it hasn't already been set.
      def extract_standard_metadata(document, calais, chunk_number)
        document.title = calais.doc_title unless document.titled?
        document.language = 'en' # TODO: Convert calais.language into an ISO language code.
        document.publication_date ||= calais.doc_date
        document.calais_id = calais.request_id
      end

      # Extract the entities that Calais discovers in the document, along with
      # the positions where they occur.
      def extract_entities(document, calais, chunk_number)
        offset = chunk_number * MAX_TEXT_SIZE
        extracted = []
        calais.entities.each do |entity|
          next unless Metadatum.acceptable_kind? entity.type
          occurrences = entity.instances.map do |instance|
            Occurrence.new(instance.offset + offset, instance.length)
          end
          extracted << Metadatum.new(
            :value        => entity.attributes['commonname'] || entity.attributes['name'],
            :kind         => DC::CALAIS_MAP[entity.type.underscore.to_sym].to_s,
            :relevance    => entity.relevance,
            :document     => document,
            :occurrences  => Occurrence.to_csv(occurrences),
            :calais_id    => entity.calais_hash.value
          )
        end
        document.metadata += extracted
      end

    end

  end
end