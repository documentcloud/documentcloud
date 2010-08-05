require File.dirname(__FILE__) + '/support/setup'

class DocumentImport < CloudCrowd::Action

  # Split a document import job into two parallel parts ... one for the image
  # generation and one for the text extraction.
  def split
    inputs_for_processing(document, 'images', 'text')
  end

  # Process runs either the text extraction or image generation, depending on
  # the input.
  def process
    @pdf = document.slug + '.pdf'
    File.open(@pdf, 'w+') {|f| f.write(asset_store.read_pdf(document)) }
    case input['task']
    when 'text'   then process_text
    when 'images' then process_images
    end
  end

  # When both sides are done, update the document to mark it as finished.
  def merge
    document.update_attributes :access => access
    document.id
  end

  # Process the image generation of the document via Docsplit, then
  # save each image with the asset store.
  def process_images
    Docsplit.extract_images(@pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :rolling => true, :output => 'images')
    Dir['images/700x/*.gif'].length.times do |i|
      image = "#{document.slug}_#{i + 1}.gif"
      asset_store.save_page_images(document, i + 1,
        {'normal'     => "images/700x/#{image}",
         'large'      => "images/1000x/#{image}",
         'thumbnail'  => "images/60x75!/#{image}"},
        access
      )
    end
  end

  def process_text
    @pages = []
    # Destroy existing text and pages to make way for the new.
    document.full_text.destroy if document.full_text
    document.pages.destroy_all if document.pages.count > 0
    Docsplit.extract_text(@pdf, :pages => 'all', :output => 'text')
    Docsplit.extract_length(@pdf).times do |i|
      page_number = i + 1
      path = "text/#{document.slug}_#{page_number}.txt"
      next unless File.exists?(path)
      text = Iconv.iconv('ascii//translit//ignore', 'utf-8', File.read(path)).first
      queue_page_text(text, page_number)
    end
    save_page_text!
    document.page_count = @pages.length
    document.full_text  = FullText.create!(:text => @pages.map{|p| p[:text] }.join(''), :document => document)
    Page.refresh_page_map(document)
    EntityDate.refresh(document)
    document.save!
    DC::Import::EntityExtractor.new.extract(document)
    upload_text_assets!
    document.id
  end


  private

  def queue_page_text(text, page_number)
    @pages.push({:text => text, :number => page_number})
  end

  def save_page_text!
    rows = @pages.map do |page|
      "(#{document.organization_id}, #{document.account_id}, #{document.id}, #{access}, #{page[:number]}, '#{PGconn.escape(page[:text])}')"
    end
    Page.connection.execute "insert into pages (organization_id, account_id, document_id, access, page_number, text) values #{rows.join(",\n")};"
  end

  # Spin up a deferred thread to upload the assets to S3 while the worker goes
  # returns the document to perform more work.
  def upload_text_assets!
    pages = document.reload.pages
    Thread.new do
      asset_store.save_full_text(document, access)
      pages.each do |page|
        asset_store.save_page_text(document, page.page_number, page.text, access)
      end
    end
  end

  # Our heuristic for this will be ... 100 bytes of text / page.
  def enough_text_detected?
    text_length = @pages.inject(0) {|sum, page| sum + page[:text].length }
    text_length > (@pages.length * 100)
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