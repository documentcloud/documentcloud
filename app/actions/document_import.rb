# Inherit Rails environment from Sinatra.
RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RAILS_ENV'] = ENV['RACK_ENV']

# Load the DocumentCloud environment if we're in a Node context.
if CloudCrowd.node?
  require 'logger'
  Object.const_set "RAILS_DEFAULT_LOGGER", Logger.new(STDOUT)
  require 'rubygems'
  require 'active_record'
  require 'config/environment'
end

class DocumentImport < CloudCrowd::Action

  def split
    ActiveRecord::Base.establish_connection
    pdf = ensure_pdf(input_path)
    basename = File.basename(pdf, '.pdf')

    # Create initial document.
    doc = Document.create!({
      :title           => options['title'] || Docsplit.extract_title(pdf) || basename,
      :source          => options['source'] || Faker::Company.name,
      :organization_id => options['organization_id'],
      :account_id      => options['account_id'],
      :access          => DC::Access::PENDING,
      :page_count      => 0
    })
    asset_store.save_pdf(doc, pdf)
    inputs_for_processing(doc, 'images', 'text')
  end

  def process
    ActiveRecord::Base.establish_connection
    @pdf      = File.basename(input['pdf'])
    @basename = File.basename(@pdf, '.pdf')
    @doc      = Document.find(input['id'])
    download(input['pdf'], @pdf)
    case input['task']
    when 'text'   then process_text
    when 'images' then process_images
    end
  end

  def merge
    ActiveRecord::Base.establish_connection
    doc = Document.find(input.first)
    doc.update_attributes :access => options['access'] || DC::Access::PUBLIC
    {'document_id' => doc.id, 'original_file' => options['original_file']}
  end

  def process_images
    Docsplit.extract_images(@pdf, :format => :jpg, :size => '60x75!', :pages => 1, :output => 'thumbs')
    asset_store.save_thumbnail(@doc, "thumbs/#{@basename}_1.jpg")
    Docsplit.extract_images(@pdf, :format => :gif, :size => ['700x', '1000x'], :output => 'images')
    Dir['images/700x/*.gif'].length.times do |i|
      page_number = i + 1
      page_name   = "#{@basename}_#{page_number}"
      page        = Page.new(:document_id => @doc.id, :page_number => page_number)
      asset_store.save_page(page, :normal_image => "images/700x/#{page_name}.gif", :large_image => "images/1000x/#{page_name}.gif")
    end
    @doc.id
  end

  def process_text
    Docsplit.extract_text(@pdf, :pages => :all, :output => 'text')
    Dir['text/*.txt'].length.times do |i|
      page_number = i + 1
      page_name   = "#{@basename}_#{page_number}"
      text        = File.read("text/#{page_name}.txt")
      page        = Page.create!(:document_id => @doc.id, :text => text, :page_number => page_number)
    end
    text            = @doc.combined_page_text
    @doc.full_text   = FullText.new(:text => text, :document => @doc)
    @doc.summary     = @doc.full_text.summary
    calais_response = fetch_rdf_from_calais(text)
    @doc.rdf = @rdf
    DC::Import::MetadataExtractor.new.extract_metadata(@doc, calais_response) if calais_response
    @doc.save!
    asset_store.save_full_text(@doc)
    @doc.id
  end


  private

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

  def inputs_for_processing(doc, *tasks)
    tasks.map {|t| {:task => t, :pdf => doc.pdf_url, :id => doc.id} }
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

  # If they've uploaded another format of document, convert it to PDF before
  # starting processing.
  def ensure_pdf(file)
    ext = File.extname(file)
    return file if ext == '.pdf'
    Docsplit.convert_to_pdf(file)
    File.basename(file, ext) + '.pdf'
  end

end