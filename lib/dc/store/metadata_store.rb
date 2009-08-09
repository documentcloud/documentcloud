module DC
  module Store
    
    # TODO: Think about keeping a separate metadata store from an instances 
    # store. The first would hold the canonical URL and the Calais attributes.
    # The second would be pure value, position, relevance, doc_id. Then you'd 
    # have to join and deal with changes to metadatum attributes over time.
  
    # The MetadataStore knows how to save and search for metadata, keyed by
    # document_id and relevance. Appropriate backing stores are Tokyo Cabinet
    # (table backend), Redis, MySQL, and potentially Solr.
    #
    # For a first pass, the metadata store will keep entries in a Tokyo Cabinet
    # table, locally. There are no indices on any of the columns, yet.
    class MetadataStore
      include DC::Store::TokyoCabinetTable
      
      def save(metadatum)
        open_for_writing {|store| store[metadatum.id] = metadatum.to_hash }
      end
      
      def save_document(document)
        open_for_writing do |store|
          document.metadata.each do |metadatum|
            store[metadatum.id] = metadatum.to_hash
          end
        end
      end
      
      # Searching for metadata that match a search_phrase. To perform a literal,
      # string equality search, pass +:literal => true+ 
      def find_by_field(type = :any, search_text = nil, opts = {})
        results = open_for_reading do |store|
          search_type = opts[:literal] ? :equals : :phrase
          store.query do |q|
            q.add_condition 'value', search_type, search_text
            q.add_condition 'type', :equals, type if type.to_sym != :any
            q.order_by 'relevance', :numdesc
            q.limit opts[:limit] if opts[:limit]
          end
        end
        results.map {|r| Metadatum.from_hash(r) }
      end
      
      # Aggregate search for the top N metadata that match a collection of
      # fields.
      def find_by_fields(fields, opts={})
        results = []
        fields.each do |field|
          results += find_by_field(field.type, field.value, opts)
        end
        sorted = results.sort_by {|meta| -meta.relevance }
        return sorted[0...opts[:limit]] if opts[:limit]
        sorted
      end
      
      # When you already have a document_id, and you want to collect the
      # most relevant metadata for that document...
      def find_by_document(document, opts = {})
        results = open_for_reading do |store|
          store.query do |q|
            q.add_condition 'document_id', :equals, document.id
            q.order_by 'relevance', :numdesc
            q.limit opts[:limit] if opts[:limit]
          end
        end
        results.map {|r| Metadatum.from_hash(r) }
      end
      
      # Compute the path to the Tokyo Cabinet Table store on disk.
      def path
        "#{RAILS_ROOT}/db/#{RAILS_ENV}_metadata.tdb"
      end
      
    end
    
  end
end