module DC
  module Store
    
    # Stores full text for a document, indexed by document_id, in a full text
    # search index (appropriate choices would be Tokyo Dystopia, Solr, 
    # Xapian, and perhaps Sphinx)
    class FullTextStore
      
      def initialize
        
      end
      
      def save(document)
        @store.save(document.id, document.full_text)
      end
      
      def find(search_text, num_results)
        @store.find(search_text, num_results)
      end
      
    end
    
  end
end