module DC
  module Store
    
    # Stores full text for a document, indexed by document_id, in a full text
    # search index (appropriate choices would be Tokyo Dystopia, Solr, 
    # Xapian, and perhaps Sphinx).
    class FullTextStore
      
      # As long as the assets have been saved first, we should lazily trigger a 
      # re-indexing of the database.
      def save(document)
        return true
      end
      
      # Find the top most relevant results.
      def find(search_text, opts={})
        entry_store   = EntryStore.new
        client        = Riddle::Client.new
        client.limit  = opts[:limit] if opts[:limit]
        results       = client.query(search_text)
        results[:matches].map {|m| entry_store.find(m[:doc].to_s(16)) }
      end
      
      # Remove a document's full-text entry from the store. Trigger a reindex,
      # if the full text has been removed from the AssetStore.
      def destroy(document)
        return true
      end
      
      # Delete the full-text store entirely.
      def delete_database!
        # FileUtils.rm_r(path) if File.exists?(path)
      end
      
    end
    
  end
end