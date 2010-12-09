require File.dirname(__FILE__) + '/support/setup'

class DocumentImport < CloudCrowd::Action

  # Split a document import job into two parallel parts ... one for the image
  # generation and one for the text extraction.
  def split
    tasks = [{'task' => 'text'  }]
    tasks << {'task' => 'images'} unless options['text_only']
    tasks
  end

  # Process runs either the text extraction or image generation, depending on
  # the input.
  def process
    begin
      @pdf = document.slug + '.pdf'
      pdf_contents = asset_store.read_pdf document
      File.open(@pdf, 'w+') {|f| f.write(pdf_contents) }
      case input['task']
      when 'text'   then process_text
      when 'images' then process_images
      end
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    document.id
  end

  # When both sides are done, update the document to mark it as finished.
  def merge
    document.update_attributes :access => access
    email_on_complete
    document.id
  end

  # Process the image generation of the document via Docsplit, then
  # save each image with the asset store.
  def process_images
    Docsplit.extract_images(@pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :rolling => true, :output => 'images')
    Dir['images/700x/*.gif'].length.times do |i|
      number = i + 1
      image  = "#{document.slug}_#{number}.gif"
      DC::Import::Utils.save_page_images(document, number, image, access)
    end
  end

  def process_text
    @pages = []
    # Destroy existing text and pages to make way for the new.
    document.full_text.destroy if document.full_text
    document.pages.destroy_all if document.pages.count > 0
    begin
      opts = {:pages => 'all', :output => 'text'}
      opts[:ocr] = true if options['force_ocr']
      Docsplit.extract_text(@pdf, opts)
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
    end
    Docsplit.extract_length(@pdf).times do |i|
      page_number = i + 1
      path = "text/#{document.slug}_#{page_number}.txt"
      text = ''
      if File.exists?(path)
        text = DC::Import::Utils.read_ascii(path)
      end
      queue_page_text(text, page_number)
    end
    save_page_text!
    document.page_count = @pages.length
    document.full_text  = FullText.create!(:text => @pages.map{|p| p[:text] }.join(''), :document => document)
    Page.refresh_page_map(document)
    EntityDate.refresh(document)
    document.save!
    pages = document.reload.pages
    Sunspot.index pages
    DC::Import::EntityExtractor.new.extract(document)
    document.upload_text_assets(pages)
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

  # Our heuristic for this will be ... 100 bytes of text / page.
  def enough_text_detected?
    text_length = @pages.inject(0) {|sum, page| sum + page[:text].length }
    text_length > (@pages.length * 100)
  end

  def email_on_complete
    count = options['email_me']
    return unless count && count > 0
    if Document.owned_by(document.account).pending.count == 0
      LifecycleMailer.deliver_documents_finished_processing(document.account, count)
    end
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

end