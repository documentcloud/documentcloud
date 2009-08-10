namespace :ingest do
  
  # NB: Oy. A rake task with both arguments and dependencies is an ugly little
  # bugger. Completely defeats the purpose of the DSL.
  desc 'Load and save all RDF from a directory of your choosing as Documents.'
  task :load_rdf, [:directory] => [:environment, :delete_databases] do |t, args|
    file_names = Dir[args[:directory] + '/*.xml']
    file_names.each do |path|
      puts "loading document from #{path}"
      doc = Document.new(:rdf => File.read(path))
      DC::Ingest::CalaisExtractor.new.extract_metadata(doc)
      doc.save
    end
  end
  
  desc "completely wipe out all existing data stores"
  task :delete_databases => :environment do
    DC::Store::AssetStore.new.delete_database!
    DC::Store::EntryStore.new.delete_database!
    DC::Store::FullTextStore.new.delete_database!
    DC::Store::MetadataStore.new.delete_database!
  end
  
end