module DC
  module Import

    # The EntityExtractor takes in a raw RDF file from OpenCalais, pulls out
    # all of the whitelisted entities we're interested in, and attaches them
    # to the document.
    class EntityExtractor

      OVER_CALAIS_QPS = '<h1>403 Developer Over Qps</h1>'

      MAX_TEXT_SIZE = CalaisFetcher::MAX_TEXT_SIZE

      # Public API: Pass in a document, either with full_text or rdf already
      # attached.
      def extract(document)
        @entities = {}
        chunks = CalaisFetcher.new.fetch_rdf(document.text)
        chunks.compact.each_with_index do |chunk, i|
          extract_information(document, chunk, i) if i == 0
          extract_entities(document, chunk, i)
        end
        document.entities = @entities.values
        document.save
      end


      private

      # Pull out all of the standard, top-level entities, and add it to our
      # document if it hasn't already been set.
      def extract_information(document, calais, chunk_number)
        document.title = calais.doc_title unless document.titled?
        document.language = 'en' # TODO: Convert calais.language into an ISO language code.
        document.publication_date ||= calais.doc_date
        document.calais_id = calais.request_id
      end

      # Extract the entities that Calais discovers in the document, along with
      # the positions where they occur.
      def extract_entities(document, calais, chunk_number)
        offset = chunk_number * MAX_TEXT_SIZE
        calais.entities.each do |entity|
          kind = Entity.normalize_kind(entity.type)
          next unless kind
          value = Entity.normalize_value(entity.attributes['commonname'] || entity.attributes['name'])
          next if kind == :phone && Validators::PHONE !~ value
          next if kind == :email && Validators::EMAIL !~ value
          occurrences = entity.instances.map do |instance|
            Occurrence.new(instance.offset + offset, instance.length)
          end
          model = Entity.new(
            :value        => value,
            :kind         => kind.to_s,
            :relevance    => entity.relevance,
            :document     => document,
            :occurrences  => Occurrence.to_csv(occurrences),
            :calais_id    => entity.calais_hash.value
          )
          if previous = @entities[model.calais_id]
            previous.merge(model)
          else
            @entities[model.calais_id] = model
          end
        end
      end

    end

  end
end