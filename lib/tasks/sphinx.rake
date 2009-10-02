namespace :sphinx do
  
  task :document_xml => :environment do
    puts DC::Import::SphinxXMLPipe.new.xml
  end
  
  task :start => :environment do
    full_text_store.start_searchd
  end
  
  task :stop => :environment do
    full_text_store.stop_searchd
  end
  
  task :restart => [:stop, :start]
  
  task :index => :environment do
    full_text_store.index
  end
  
  task :rebuild => [:stop, :index, :start]
  
  task :status => :environment do
    puts full_text_store.searchd_status
  end
  
end

def full_text_store
  @full_text_store ||= DC::Store::FullTextStore.new
end