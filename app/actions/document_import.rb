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
    pdf       = ensure_pdf(input_path)
    basename  = File.basename(pdf, '.pdf')
    asset_store.save_pdf(document, pdf)
    inputs_for_processing(document, 'images', 'text')
  end

  def process
    @pdf      = File.basename(input['pdf'])
    @basename = File.basename(@pdf, '.pdf')
    download(input['pdf'], @pdf)
    case input['task']
    when 'text'   then process_text
    when 'images' then process_images
    end
  end

  def merge
    document.update_attributes :access => options['access'] || DC::Access::PUBLIC
    {'document_id' => document.id, 'original_file' => options['original_file']}
  end

  def process_images
    Docsplit.extract_images(@pdf, :format => :jpg, :size => '60x75!', :pages => 1, :output => 'thumbs')
    asset_store.save_thumbnail(document, "thumbs/#{@basename}_1.jpg")
    Docsplit.extract_images(@pdf, :format => :gif, :size => ['700x', '1000x'], :output => 'images')
    Dir['images/700x/*.gif'].length.times do |i|
      image = "#{@basename}_#{i + 1}.gif"
      asset_store.save_page_images(
        Page.new(:document_id => document.id, :page_number => i + 1),
        :normal_image => "images/700x/#{image}",
        :large_image => "images/1000x/#{image}"
      )
    end
  end

  def process_text
    pages = []
    extractor = DC::Import::TextExtractor.new(@pdf)
    if extractor.contains_text?
      Docsplit.extract_text(@pdf, :pages => :all, :output => 'text')
      Dir['text/*.txt'].length.times do |i|
        save_page_text(File.read("text/#{@basename}_#{i + 1}.txt"), i + 1)
      end
    else
      Docsplit.extract_pages(@pdf, :output => 'text')
      Dir['text/*.pdf'].length.times do |i|
        text = DC::Import::TextExtractor.new("text/#{@basename}_#{i + 1}.pdf").text_from_ocr
        save_page_text(text, i + 1)
      end
    end
    text                = document.combined_page_text
    document.full_text  = FullText.new(:text => text, :document => document)
    document.summary    = document.full_text.summary
    document.save!
    DC::Import::MetadataExtractor.new.extract_metadata(document)
    asset_store.save_full_text(document)
    document.id
  end


  private

  def save_page_text(text, page_number)
    page = Page.create!(:document => document, :text => text, :page_number => page_number)
    asset_store.save_page_text(page)
  end

  def document
    return @document if @document
    ActiveRecord::Base.establish_connection
    @document = Document.find(options['id'])
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

  def inputs_for_processing(doc, *tasks)
    tasks.map {|t| {:task => t, :pdf => doc.pdf_url, :id => doc.id} }
  end

  # If they've uploaded another format of document, convert it to PDF before
  # starting processing.
  def ensure_pdf(file)
    ext = File.extname(file)
    return file if ext == '.pdf'
    Docsplit.extract_pdf(file)
    File.basename(file, ext) + '.pdf'
  end

end