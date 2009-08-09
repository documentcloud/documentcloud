module DC
  module Stores
    
    # The EntryStore is responsible for keeping a denormalized (in theory, the
    # attributes could be rebuilt from the MetadataStore) representation of a 
    # document's linked data.
    #
    # Potential backing engines for this store are MySQL, MongoDB, Tokyo Cabinet
    # (either hash or table backends).
    class EntryStore
      
      def initialize
        
      end
      
      def save(document)
        @store.put(document.id, document.to_entry.to_json)
      end
      
      def find(document_id)
        Document.revivify(@store.find(document_id))
      end
      
    end
    
  end
end