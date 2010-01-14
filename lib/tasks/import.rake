namespace :import do

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