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
  
end