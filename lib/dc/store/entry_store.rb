module DC
  module Store
    
    # The EntryStore is responsible for keeping a denormalized (in theory, the
    # attributes could be rebuilt from the MetadataStore) representation of a 
    # document's linked data.
    #
    # Potential backing engines for this store are MySQL, MongoDB, Tokyo Cabinet
    # (either hash or table backends).
    class EntryStore
      include DC::Store::TokyoTyrantTable
      
      # Creating an EntryStore sets the host and port.
      def initialize
        @host, @port = DC_CONFIG['entry_store'].split(':')
        @port = @port.to_i
      end
      
      # Save a document's entry attributes.
      def save(document)
        open_for_writing do |store|
          hash = document.to_entry_hash
          id = hash.delete('id')
          store[id] = hash
        end
      end
      
      # Find a document's entry, referenced by document id.
      def find(document_id)
        doc_hash = open_for_reading {|store| store[document_id] }
        raise DocumentNotFound, "Could not find document with id: #{document_id}" if !doc_hash
        Document.new(doc_hash.merge('id' => document_id))
      end
      
      def find_all(document_ids)
        results = query do |q| 
          q.add '', :stroreq, document_ids.join(' ')
        end
        results.map {|r| Document.new(r) }
      end
      
      def find_by_attributes(attributes, opts = {})
        results = query do |q|
          attributes.each {|field| q.add field.type, :phrase, field.value }
          q.add 'access', :numeq, DC::Access::PUBLIC
          q.pk_only
          q.limit opts[:limit] if opts[:limit]
        end
        results.map {|r| Document.new('id' => r) }
      end
      
      # Get a list of every single document id in the database.
      def document_ids
        open_for_reading {|store| store.keys }
      end
      
      # Get a list of every document id that's been added since a given moment.
      def document_ids_since(unix_time)
        results = query do |q|
          q.pk_only
          q.add 'created_at', :gt, unix_time
        end
      end
      
      # Delete a document's entry from the store.
      def destroy(document)
        open_for_writing {|store| store.delete(document.id) }
      end
      
      # Compute the path to the Tokyo Cabinet Table store on disk.
      def path
        "#{RAILS_ROOT}/db/#{RAILS_ENV}_entries.tct"
      end
      
      # Delete the entry store entirely.
      def delete_database!
        FileUtils.rm(path) if File.exists?(path)
      end
      
    end
    
  end
end