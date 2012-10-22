require File.dirname(__FILE__) + '/support/setup'

class DocumentImport < CloudCrowd::Action
  
  # Split a document import job into two parallel parts ... one for the image
  # generation and one for the text extraction.
  # If the Document was not originally uploaded, but was passed as a remote URL
  # instead, download it first, convert it to a PDF ... then go to town.
  def split
    if options['url']
      file = File.basename(options['url'])
      File.open(file, 'w') do |f|
        url = URI.parse(options['url'])
        Net::HTTP.start(url.host, url.port) do |http|
          http.request_get(url.path) do |res|
            res.read_body do |seg|
              f << seg
              sleep 0.005 # To allow the buffer to fill (more).
            end
          end
        end
      end
    else
      file = File.basename document.original_file_path
      File.open(file, 'w'){ |f| f << DC::Store::AssetStore.new.read_original(document) }
    end
    File.open(file, 'r') do |f|
      DC::Import::PDFWrangler.new.ensure_pdf(f, file) do |path|
        DC::Store::AssetStore.new.save_pdf(document, path, access)
      end
    end
    tasks = []
    tasks << {'task' => 'text'} unless options['images_only']
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

      document.update_file_metadata

      case input['task']
      when 'text'   then process_text
      when 'images' then process_images
      end
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e, options)
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


  # Check if there is a duplicate of the document already in the system
  # if so, copy it into the appropriate bucket,
  # otherwise process the image generation of the document via Docsplit, then
  # save each image with the asset store.
  def process_images
    if document.duplicates.empty?
      Docsplit.extract_images(@pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :rolling => true, :output => 'images')
      Dir['images/700x/*.gif'].length.times do |i|
        number = i + 1
        image  = "#{document.slug}_#{number}.gif"
        DC::Import::Utils.save_page_images(asset_store, document, number, image, access)
      end
    else
      asset_store.copy_assets( document.duplicates.first, document )
    end
  end

  def process_text
    @pages = []
    # Destroy existing text and pages to make way for the new.
    document.pages.destroy_all if document.pages.count > 0
    begin
      opts = {:pages => 'all', :output => 'text', :language => ocr_language(document.language)}
      opts[:ocr] = true if options['force_ocr']
      opts[:clean] = false unless opts[:language] == 'eng'
      Docsplit.extract_text(@pdf, opts)
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e, options)
    end
    Docsplit.extract_length(@pdf).times do |i|
      page_number = i + 1
      path = "text/#{document.slug}_#{page_number}.txt"
      text = ''
      if File.exists?(path)
        text = if document.language == 'en'
          DC::Import::Utils.read_ascii(path)
        else
          File.read(path)
        end
      end
      queue_page_text(text, page_number)
    end
    save_page_text!
    text = @pages.map{|p| p[:text] }.join('')
    document.page_count = @pages.length
    Page.refresh_page_map(document)
    EntityDate.reset(document)
    document.save!
    pages = document.reload.pages
    Sunspot.index pages
    DC::Import::EntityExtractor.new.extract(document, text) unless options['secure'] or not DC::Language::SUPPORTED.include? document.language
    document.upload_text_assets(pages, access)
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

  # Check if there are no more pending documents, then email the user based on
  # the original count. This is a bit optimistic, as the first document could
  # finish processing before the second document is finished uploading.
  # In which case, the user would be emailed twice.
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
  
  def ocr_language(two_letter)
    {
      'en' => 'eng',
      'es' => 'spa'
    }[two_letter] || 'eng'
  end

end
