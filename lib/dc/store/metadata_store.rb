module DC
  module Store
    
    # TODO: Think about keeping a separate metadata store from an instances 
    # store. The first would hold the canonical URL and the Calais attributes.
    # The second would be pure value, position, relevance, doc_id. Then you'd 
    # have to join and deal with changes to metadatum attributes over time.
  
    # The MetadataStore knows how to save and search for metadata, keyed by
    # document_id and relevance. Appropriate backing stores are Tokyo Cabinet
    # (table backend), Redis, MySQL, SimpleDB, and potentially Solr.
    #
    # For a first pass, the metadata store will keep entries in a Tokyo Cabinet
    # table, locally. There are no indices on any of the columns, yet.
    class MetadataStore
      include DC::Store::TokyoTyrantTable
      
      PROBABLY_AN_ACRONYM = /\A[A-Z]{2,6}\Z/
      
      def save_to(store, metadatum)
        hash = metadatum.to_hash
        id = hash.delete('id')
        store[id] = hash
      end
      
      def save(metadatum)
        open_for_writing {|store| save_to(store, metadatum) }
      end
      
      def save_document(document)
        open_for_writing {|store| document.metadata.each {|m| save_to(store, m) }}
      end
      
      # Remove all of a document's metadata occurrences from the store.
      def destroy_document(document)
        open_for_writing {|store| store.delete_keys_with_prefix(document.metadata_prefix) }
      end
      
      # Searching for metadata that match a search_phrase. To perform a literal,
      # string equality search, pass +:literal => true+ 
      # Tries to be smart and detect searches that should be literal.
      def find_by_field(type = :any, search_text = nil, opts = {})
        acronym = !!search_text.match(PROBABLY_AN_ACRONYM)
        search_type = opts[:literal] || acronym ? :equals : :phrase
        results = query do |q|
          q.add 'value', search_type, search_text
          q.add 'type', :equals, type if type.to_sym != :any
          q.order_by 'relevance', :numdesc
          q.limit opts[:limit] if opts[:limit]
        end
        results.map {|r| Metadatum.from_hash(r) }
      end
      
      # Aggregate search for the top N metadata that match a collection of
      # fields. Uses AND for now.
      def find_by_fields(fields, opts={})
        results = []
        fields.each {|f| results << find_by_field(f.type, f.value, opts) }
        first = results.shift
        results = first.select {|m| results.all? {|list| list.any? {|o| m.document_id == o.document_id}}}
        results = results.sort_by {|meta| -meta.relevance }
        return results[0...opts[:limit]] if opts[:limit]
        results.map {|meta| Document.new('id' => meta.document_id) }
      end
      
      # When you already have a document_ids, and you want to collect the
      # most relevant metadata for those documents...
      def find_by_documents(documents, opts={})
        results = search(:union) do |store|
          documents.map do |doc|
            store.prepare_query do |q|
              q.add '', :includes, "/#{doc.id}/"
              q.limit opts[:limit] if opts[:limit]
            end
          end
        end
        results.map {|key, value| Metadatum.from_hash(value.merge('id' => key)) }
      end
      
      # Compute the path to the Tokyo Cabinet Table store on disk.
      def path
        "#{RAILS_ROOT}/db/#{RAILS_ENV}_metadata.tct"
      end
      
      def port
        DC_CONFIG['metadata_store_port']
      end
      
      # Delete the metadata store entirely. And its indices.
      def delete_database!
        FileUtils.rm(path) if File.exists?(path)
        Dir[path.sub(/\.tct\Z/, '*.lex')].each {|index| FileUtils.rm(index) }
      end
      
    end
    
  end
end