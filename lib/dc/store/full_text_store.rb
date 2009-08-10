module DC
  module Store
    
    # Stores full text for a document, indexed by document_id, in a full text
    # search index (appropriate choices would be Tokyo Dystopia, Solr, 
    # Xapian, and perhaps Sphinx).
    class FullTextStore
      
      def save(document)
        open_for_writing do |store|
          store.store(document.integer_id, document.full_text)
        end
      end
      
      # TODO: If Tokyo Dystopia doesn't support limiting search results to the
      # top N most relevant, then we're going to need to use something else.
      def find(search_text, opts={})
        entry_store = EntryStore.new
        int_ids = open_for_reading do |store|
          store.search(search_text)
        end
        int_ids = int_ids[0...opts[:limit]] if opts[:limit]
        doc_ids = int_ids.map {|id| id.to_s(16) }
        doc_ids.map {|id| entry_store.find(id) }
      end
      
      def path
        "#{RAILS_ROOT}/db/#{RAILS_ENV}_full_text"
      end
      
      # Delete the full-text store entirely.
      def delete_database!
        FileUtils.rm_r(path) if File.exists?(path)
      end
      
      
      private
      
      def open_for_writing
        begin
          store = Rufus::Tokyo::Dystopia::Core.new(path, 'a')
          result = yield(store)
        ensure
          store.close
        end
        result
      end
      
      def open_for_reading
        begin
          store = Rufus::Tokyo::Dystopia::Core.new(path, 'r')
          result = yield(store)
        ensure
          store.close
        end
        result
      end
      
    end
    
  end
end

# Opens up the store on disk for reading.
def open_for_reading
  begin
    store = Rufus::Tokyo::Table.new(path, :mode => 'r', :opts => 'ld')
    result = yield(store)
  ensure
    store.close
  end
  result
end