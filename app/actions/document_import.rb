require File.dirname(__FILE__) + '/support/setup'

class DocumentImport < CloudCrowd::Action

  def split
    inputs_for_processing(document, 'images', 'text')
  end

  def process
    @pdf = document.slug + '.pdf'
    File.open(@pdf, 'w+') {|f| f.write(asset_store.read_pdf(document)) }
    case input['task']
    when 'text'   then process_text
    when 'images' then process_images
    end
  end

  def merge
    document.update_attributes :access => access
    document.id
  end

  def process_images
    Docsplit.extract_images(@pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :rolling => true, :output => 'images')
    Dir['images/700x/*.gif'].length.times do |i|
      image = "#{document.slug}_#{i + 1}.gif"
      asset_store.save_page_images(
        Page.new(:document_id => document.id, :page_number => i + 1),
        {'normal'     => "images/700x/#{image}",
         'large'      => "images/1000x/#{image}",
         'thumbnail'  => "images/60x75!/#{image}"},
        access
      )
    end
  end

  def process_text
    # Destroy existing text and pages to make way for the new.
    document.full_text.destroy if document.full_text
    extractor = DC::Import::TextExtractor.new(@pdf)
    if extractor.contains_text?
      begin
        pdf_text
      rescue Exception => e
        ocr_text
      end
    else
      ocr_text
    end
    ocr_text unless enough_text_detected?(document)
    document.full_text = FullText.create!(:text => document.combined_page_text, :document => document)
    Page.refresh_page_map(document)
    EntityDate.refresh(document)
    document.save!
    DC::Import::EntityExtractor.new.extract(document)
    asset_store.save_full_text(document, access)
    document.id
  end


  private

  def pdf_text
    document.pages.destroy_all if document.pages.count > 0
    Docsplit.extract_text(@pdf, :pages => 'all', :output => 'text')
    Dir['text/*.txt'].length.times do |i|
      path = "text/#{document.slug}_#{i + 1}.txt"
      next unless File.exists?(path)
      text = File.read(path)
      save_page_text(text, i + 1)
    end
  end

  def ocr_text
    document.pages.destroy_all if document.pages.count > 0
    Docsplit.extract_pages(@pdf, :output => 'text')
    Dir['text/*.pdf'].length.times do |i|
      path = "text/#{document.slug}_#{i + 1}.pdf"
      next unless File.exists?(path)
      text = DC::Import::TextExtractor.new(path).text_from_ocr
      save_page_text(text, i + 1)
    end
  end

  def save_page_text(text, page_number)
    page = Page.create!(:document => document, :text => text, :page_number => page_number)
    asset_store.save_page_text(page, access)
  end

  # Our heuristic for this will be ... 100 characters / page.
  def enough_text_detected?(document)
    text_length = (Page.calculate(:sum, "length(text)", :conditions => {:document_id => document.id})).to_i
    text_length > (document.pages.count * 100)
  end

  def document
    return @document if @document
    ActiveRecord::Base.establish_connection
    @document = Document.find(options['id'])
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

  def access
    options['access'] || DC::Access::PRIVATE
  end

  def inputs_for_processing(doc, *tasks)
    tasks.map {|t| {:task => t, :id => doc.id} }
  end

end