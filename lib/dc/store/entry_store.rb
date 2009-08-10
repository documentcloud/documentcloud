module DC
  module Store
    
    # The EntryStore is responsible for keeping a denormalized (in theory, the
    # attributes could be rebuilt from the MetadataStore) representation of a 
    # document's linked data.
    #
    # Potential backing engines for this store are MySQL, MongoDB, Tokyo Cabinet
    # (either hash or table backends).
    class EntryStore
      include DC::Store::TokyoCabinetTable
      
      # Save a document's entry attributes.
      def save(document)
        open_for_writing do |store|
          store[document.id] = document.to_entry_hash
        end
      end
      
      # Find a document's entry, referenced by document id.
      def find(document_id)
        doc_hash = open_for_reading {|store| store[document_id] }
        raise DocumentNotFound, "Could not find document with id: #{document_id}" if !doc_hash
        Document.from_entry_hash(doc_hash)
      end
      
      # Compute the path to the Tokyo Cabinet Table store on disk.
      def path
        "#{RAILS_ROOT}/db/#{RAILS_ENV}_entries.tdb"
      end
      
      # Delete the entry store entirely.
      def delete_database!
        FileUtils.rm(path) if File.exists?(path)
      end
      
    end
    
  end
end