# Inherit Rails environment from Sinatra.
RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RAILS_ENV'] = ENV['RACK_ENV']

# Load the DocumentCloud environment if we're in a Node context.
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
  
  def split
    log_exceptions do
      ActiveRecord::Base.establish_connection
      # Extract document-wide assets: title, thumbnails, rdf.
      extract_title(input_path)
      generate_thumbnails(input_path)
      # Create a naked document record in the database (we'll need the id).
      doc = Document.create!({
        :title           => options['title'] || @title,
        :source          => options['source'] || Faker::Company.name,
        :organization_id => options['organization_id'],
        :account_id      => options['account_id'],
        :access          => options['access'] || DC::Access::PUBLIC,
        :page_count      => 0
      })
      DC::Store::AssetStore.new.save_files(doc, :pdf => input_path, :thumbnail => @thumb_path)
      # Split the document into pages for further (parallel) processing.
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
      input['document_id']
    end
  end
  
  # After all of the document's pages have been imported, we combine their text
  # to produce the document's full_text, and send it to Calais for entity
  # extraction.
  def merge
    doc = Document.find(input.first)
    text = doc.combined_page_text
    doc.full_text = FullText.new(:text => text, :document => doc)
    doc.summary = text[0...255]
    calais_response = fetch_rdf_from_calais(text)
    doc.rdf = @rdf
    DC::Import::MetadataExtractor.new.extract_metadata(doc, calais_response) if calais_response
    doc.save!
    DC::Store::AssetStore.new.save_full_text(doc)
    doc.id
  end

  
  private
  
  # Split the pdf up into individual pages, and archive them in batches.
  def split_into_pages(document)
    wrangler = DC::Import::PDFWrangler.new
    pdfs = wrangler.burst(input_path)
    tars = wrangler.archive(pdfs, options['batch_size'])
    tars.map {|tar| {'document_id' => document.id, 'batch_url' => save(tar)} }
  end
  
  # Import and save a single page of a document, including text and images.
  def import_page(page_pdf)
    page_number = page_pdf.match(/(\d+)\.pdf$/)[1].to_i
    extract_full_text(page_pdf)
    generate_page_images(page_pdf)
    page = Page.create!(:document_id => input['document_id'], :text => @text, :page_number => page_number)
    DC::Store::AssetStore.new.save_page(page, :normal_image => @normal_page_image, :large_image => @large_page_image)
    page.id
  end
  
  # TODO: clean up the errors that we want to retry only -- add calais exception
  # classes to the gem.
  def fetch_rdf_from_calais(text)
    begin
      @rdf = DC::Import::CalaisFetcher.new.fetch_rdf(text)
      return Calais::Response.new(@rdf)
    rescue Calais::Error, Curl::Err => e
      puts e.message
      return @rdf = nil if e.message == 'Calais continues to expand its list of supported languages, but does not yet support your submitted content.'
      puts 'waiting 10 seconds'
      sleep 10
      retry
    end
  end
  
  # Extract the full text of a PDF (or sub-page), using pdftotext or OCR.
  def extract_full_text(path)
    @text = DC::Import::TextExtractor.new(path).get_text
  end
  
  # Extract the title of the PDF.
  def extract_title(path)
    @title = DC::Import::TextExtractor.new(path).get_title || file_name
  end
  
  # Extract all the requisite thumbnails for the Document from the PDF.
  def generate_thumbnails(path)
    image_ex = DC::Import::ImageExtractor.new(input_path).get_thumbnails
    @thumb_path = image_ex.thumbnail_path
  end
  
  # Extract all the sized page images for a single page of a PDF.
  def generate_page_images(path)
    image_ex = DC::Import::ImageExtractor.new(path).get_page_images
    @normal_page_image = image_ex.normal_page_image
    @large_page_image = image_ex.large_page_image
  end
  
  # Run a block, printing out full exceptions before raising them.
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