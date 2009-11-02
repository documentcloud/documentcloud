namespace :import do
  
  # Usage: rake import:load_rdf[../wiki_news_rdf] --trace
  desc 'Load and save all RDF files from a directory of your choosing as Documents.'
  task :load_rdf, [:directory] => [:environment] do |t, args|
    file_names = Dir[args[:directory] + '/*.xml']
    file_names.each do |path|
      print "loading #{path}"
      doc = Document.new(:rdf => File.read(path), :organization_id => 0, :account_id => 0, :access => DC::Access::PUBLIC, :page_count => 1)
      DC::Import::MetadataExtractor.new.extract_metadata(doc)
      doc.source ||= Faker::Company.name
      puts " / saving #{doc.title}"
      doc.save!
    end
  end
  
  # Usage: rake import:load_pdf[../presidential_papers] --trace
  desc 'Load and save all PDF files from a directory of your choosing as Documents.'
  task :load_pdf, [:directory] => [:environment] do |t, args|
    file_names = Dir[args[:directory] + '/*.pdf']
    file_names.each do |path|
      print "loading #{path}"
      ex = DC::Import::TextExtractor.new(path)
      text, title = ex.get_text, (ex.get_title || "Untitled Document")
      image_ex = DC::Import::ImageExtractor.new(path)
      image_ex.get_thumbnails
      doc = Document.new(
        :full_text            => text, 
        :title                => title, 
        :pdf                  => path,
        :thumbnail            => image_ex.thumbnail_path,
        :small_thumbnail      => image_ex.small_thumbnail_path,
        :organization_id      => 0, 
        :account_id           => 0, 
        :access => DC::Access::PUBLIC
      )
      DC::Import::MetadataExtractor.new.extract_metadata(doc)
      doc.source ||= Faker::Company.name
      puts " / saving as #{doc.id}"
      doc.save
    end
    fts = DC::Store::FullTextStore.new
    fts.index
    fts.merge
  end
  
  # Usage: rake import:cloud_crowd_pdf[../congressional_documents] --trace
  desc 'Load and save all PDF files from a directory of your choosing via CloudCrowd.'
  task :cloud_crowd_pdf, [:directory] => [:environment] do |t, args|
    urls = Dir[args[:directory] + "/*.pdf"].map {|pdf| "file://#{File.expand_path(pdf)}" }
    DC::Import::CloudCrowdImporter.new.import(urls)
  end
  
  desc 'Load all PDF files from public/docs via CloudCrowd.'
  task :public_docs_pdf => :environment do
    Dir.chdir("#{RAILS_ROOT}/public") do
      urls = Dir['docs/**/*.pdf'].map {|pdf| "#{DC_CONFIG['server_root']}/#{pdf}"}
      DC::Import::CloudCrowdImporter.new.import(urls)
    end
  end
  
end