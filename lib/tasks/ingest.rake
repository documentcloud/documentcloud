namespace :ingest do
  
  # NB: Oy. A rake task with both arguments and dependencies is an ugly little
  # bugger. Completely defeats the purpose of the DSL.
  desc 'Load and save all RDF from a directory of your choosing as Documents.'
  task :load_rdf, [:directory] => [:environment] do |t, args|
    file_names = Dir[args[:directory] + '/*.xml']
    file_names.each do |path|
      puts "loading document from #{path}"
      doc = Document.new(:rdf => File.read(path))
      DC::Ingest::CalaisExtractor.new.extract_metadata(doc)
      doc.save
    end
  end
  
end