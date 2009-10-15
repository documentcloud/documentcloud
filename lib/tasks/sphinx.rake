namespace :sphinx do
  
  task :cloud_crowd_pdf, [:directory] => [:environment] do |t, args|
    urls = Dir[args[:directory] + "/*.pdf"].map {|pdf| "file://#{File.expand_path(pdf)}" }
    DC::Import::CloudCrowdImporter.new.import(urls)
  end
  
  task :document_xml, [:delta] => [:environment] do |t, args|
    pipe = DC::Import::SphinxXMLPipe.new
    puts args[:delta] == 'delta' ? pipe.delta_xml : pipe.all_xml
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
    full_text_store.merge
  end
  
  task :index_all => :environment do
    full_text_store.index_all
  end
  
  task :rebuild => [:stop, :index_all, :start]
  
  task :status => :environment do
    puts full_text_store.searchd_status
  end
  
end

def full_text_store
  @full_text_store ||= DC::Store::FullTextStore.new
end