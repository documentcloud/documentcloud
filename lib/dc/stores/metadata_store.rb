module DC
  module Stores
    
    # TODO: Think about keeping a separate metadata store from an instances 
    # store. The first would hold the canonical URL and the Calais attributes.
    # The second would be pure value, position, relevance, doc_id. Then you'd 
    # have to join and deal with changes to metadatum attributes over time.
  
    # The MetadataStore knows how to save and search for metadata, keyed by
    # document_id and relevance. Appropriate backing stores are Tokyo Cabinet
    # (table backend), Redis, MySQL, and potentially Solr.
    #
    # For a first pass, the metadata store will keep entries in a Tokyo Cabinet
    # table, locally. 
    class MetadataStore
      include DC::Stores::TokyoCabinetTable
      
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
      
      # Searching for metadata that mach a value does a precise string equality
      # for now. TCTDB also supports tokenized searches, numerical searches,
      # regex-based searches, and full-text searches.
      def find_by_value(value, num_results = nil)
        results = open_for_reading do |store|
          store.query do |q|
            q.add_condition 'value', :equals, value
            q.order_by 'relevance', :numdesc
            q.limit num_results if num_results
          end
        end
        results.map {|r| Metadatum.from_hash(r) }
      end
      
      # When you already have a document_id, and you want to collect the
      # most relevant metadata for that document...
      def find_by_document(document, num_results = nil)
        results = open_for_reading do |store|
          store.query do |q|
            q.add_condition 'document_id', :equals, document.id
            q.order_by 'relevance', :numdesc
            q.limit num_results if num_results
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