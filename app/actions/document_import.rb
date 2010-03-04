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
    Docsplit.extract_images(@pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :output => 'images')
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
    document.pages.destroy_all if document.pages.count > 0
    pages = []
    extractor = DC::Import::TextExtractor.new(@pdf)
    if extractor.contains_text?
      Docsplit.extract_text(@pdf, :pages => :all, :output => 'text')
      Dir['text/*.txt'].length.times do |i|
        save_page_text(File.read("text/#{document.slug}_#{i + 1}.txt"), i + 1)
      end
    else
      Docsplit.extract_pages(@pdf, :output => 'text')
      Dir['text/*.pdf'].length.times do |i|
        text = DC::Import::TextExtractor.new("text/#{document.slug}_#{i + 1}.pdf").text_from_ocr
        save_page_text(text, i + 1)
      end
    end
    text                 = document.combined_page_text
    document.full_text   = FullText.new(:text => text, :document => document)
    # document.description = document.full_text.summarize
    Page.refresh_page_map(document)
    MetadataDate.refresh(document)
    document.save!
    meta_extractor      = DC::Import::MetadataExtractor.new
    meta_extractor.extract_metadata(document)
    # asset_store.save_rdf(document, meta_extractor.rdf, DC::Access::PRIVATE)
    asset_store.save_full_text(document, access)
    document.id
  end


  private

  def save_page_text(text, page_number)
    page = Page.create!(:document => document, :text => text, :page_number => page_number)
    asset_store.save_page_text(page, access)
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