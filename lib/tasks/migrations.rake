namespace :migrate do
  
  desc "migrate the entry.organization column over to be entry.source"
  task :sources => :environment do
    DC::Store::EntryStore.new.open_for_writing do |store|
      store.keys.each do |doc_id|
        doc = store[doc_id]
        doc['source'] = doc.delete('organization')
        store[doc_id] = doc
      end
    end
  end
  
  desc "migrate the entries, full text, and metadata over to access-controlled forms"
  task :access_control => :environment do
    entry_store = DC::Store::EntryStore.new
    metadata_store = DC::Store::MetadataStore.new
    doc_ids = entry_store.open_for_reading {|store| store.keys }
    entry_store.open_for_writing do |store|
      doc_ids.each do |doc_id|
        entry = store[doc_id]
        entry.delete('id')
        entry['organization_id'] = entry['account_id'] = 0
        entry['access'] = DC::Access::PUBLIC
        puts "saving document #{doc_id}"
        store[doc_id] = entry
        metadata_store.open_for_writing do |mstore|
          metas = mstore.query do |q| 
            q.no_pk(false)
            q.add('', :starts_with, doc_id)
          end
          metas.each do |meta|
            meta.delete('document_id')
            id = meta.delete('id')
            meta['access'] = entry['access']
            mstore.delete(id)
            new_id = "#{doc_id}/0/0/#{meta['calais_hash'] || meta['value']}"
            puts "saving metadatum #{new_id}"
            mstore[new_id] = meta
          end
        end
      end
    end
    puts "re-indexing full text"
    DC::Store::FullTextStore.new.index
  end
  
end