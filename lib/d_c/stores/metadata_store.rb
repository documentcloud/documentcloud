module DC
  module Stores
    
    # TODO: Think about keeping a separate metadata store from an instances 
    # store. The first would hold the canonical URL and the Calais attributes.
    # The second would be pure value, position, relevance, doc_id. Then you'd 
    # have to join and deal with changes to metadatum attributes over time.
  
    # The MetadataStore knows how to save and search for metadata, keyed by
    # document_id and relevance. Appropriate backing stores are Tokyo Cabinet
    # (table backend), Redis, MySQL, and potentially Solr. 
    class MetadataStore
      
      def initialize
        
      end
      
      def save_metadatum(metadatum)
        @store.save(metadatum.document.id, metadatum.value, metadatum.relevance)
      end
      
      def find_by_value(value, num_results)
        @store.find_top_relevant_metadata_by_value(value, num_results)
      end
      
      def metadata_for_document(document, num_results)
        @store.find_most_relevant_metadata_for_document(document, num_results)
      end
      
    end
  
  end
end