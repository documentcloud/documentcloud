#######################################################
######### HUGE MESS. SPRING CLEANING NEEDED. ##########
#######################################################

RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RAILS_ENV'] = ENV['RACK_ENV']

if CloudCrowd.node?
  require 'rubygems'
  require 'activerecord'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  require 'config/environment'
end

# DocumentCloud import produces full text, RDF from OpenCalais, and thumbnails
# from a PDF document. The calling DocumentCloud instance is responsible for
# downloading and ingesting these resources.
class DocumentImport < CloudCrowd::Action
  
  DEFAULT_BATCH_SIZE = 5
  
  def split
    log_exceptions do
      ActiveRecord::Base.establish_connection
      extract_full_text
      extract_title
      generate_thumbnails
      calais_response = fetch_rdf_from_calais
      doc = Document.new({
        :title           => options['title'] || @title,
        :source          => options['source'] || Faker::Company.name,
        :organization_id => options['organization_id'],
        :account_id      => options['account_id'],
        :access          => options['access'] || DC::Access::PUBLIC,
        :rdf             => @rdf,
        :summary         => @text[0...255],
        :page_count      => 0
      })
      doc.full_text = FullText.new(:text => @text, :document => doc)
      DC::Import::MetadataExtractor.new.extract_metadata(doc, calais_response) if calais_response
      doc.save!
      DC::Store::AssetStore.new.save(doc, :pdf => input_path, :thumbnail => @thumb_path)
      split_into_pages(doc)
    end
  end
  
  # Process handles an individual batch of pages.
  def process
    log_exceptions do
      tar = File.basename(input['batch_url'])
      download(input['batch_url'], tar)
      `tar -xzf #{tar}`
      ActiveRecord::Base.establish_connection
      Dir['*.pdf'].map {|page_pdf| import_page(page_pdf) }
    end
  end
  
  # The double pdftk shuffle fixes the document xrefs.
  def split_into_pages(document)
    `pdftk #{input_path} burst output "#{file_name}_%05d.pdf_temp"`
    FileUtils.rm input_path
    pdfs = Dir["*.pdf_temp"]
    pdfs.each {|pdf| `pdftk #{pdf} output #{File.basename(pdf, '.pdf_temp')}.pdf`}
    pdfs = Dir["*.pdf"]
    batch_size = options['batch_size'] || DEFAULT_BATCH_SIZE
    batches = (pdfs.length / batch_size.to_f).ceil
    batches.times do |batch_num|
      tar_path = "#{sprintf('%05d', batch_num)}.tar"
      batch_pdfs = pdfs[batch_num*batch_size...(batch_num + 1)*batch_size]
      `tar -czf #{tar_path} #{batch_pdfs.join(' ')}`
    end
    Dir["*.tar"].map do |tar| 
      {'document_id' => document.id, 'batch_url' => save(tar)}
    end
  end
  
  def import_page(page_pdf)
    page_number = page_pdf.match(/(\d+)\.pdf$/)[1].to_i
    extract_full_text(page_pdf)
    generate_page_images(page_pdf)
    page = Page.create!(:document_id => input['document_id'], :text => @text, :page_number => page_number)
    DC::Store::AssetStore.new.save_page(page, :normal_image => @normal_page_image, :large_image => @large_page_image)
    page.id
  end
  
  def extract_full_text(path=nil)
    ex = DC::Import::TextExtractor.new(path || input_path)
    @text = ex.get_text
  end
  
  def extract_title(path=nil)
    ex = DC::Import::TextExtractor.new(path || input_path)
    @title = ex.get_title || File.basename(input, File.extname(input))
  end
  
  def generate_thumbnails
    image_ex = DC::Import::ImageExtractor.new(input_path).get_thumbnails
    @thumb_path = image_ex.thumbnail_path
  end
  
  def generate_page_images(path=nil)
    image_ex = DC::Import::ImageExtractor.new(path).get_page_images
    @normal_page_image = image_ex.normal_page_image
    @large_page_image = image_ex.large_page_image
  end
  
  # TODO: clean up the errors that we want to retry only -- add calais exception
  # classes to the gem.
  def fetch_rdf_from_calais
    path = "#{work_directory}/#{file_name}.rdf"
    begin
      @rdf = DC::Import::CalaisFetcher.new.fetch_rdf(@text)
      return Calais::Response.new(@rdf)
    rescue Calais::Error, Curl::Err => e
      puts e.message
      return @rdf = nil if e.message == 'Calais continues to expand its list of supported languages, but does not yet support your submitted content.'
      puts 'waiting 10 seconds'
      sleep 10
      retry
    end
  end

  
  private
  
  def log_exceptions
    begin
      yield
    rescue Exception => e
      puts e.class.to_s
      puts e.message
      puts e.backtrace
      raise e
    end
  end
  
end