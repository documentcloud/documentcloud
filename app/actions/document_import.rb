require File.join(File.dirname(__FILE__), 'support', 'document_action')
class DocumentImport < DocumentAction
  
  # Split a document import job into two parallel parts ... one for the image
  # generation and one for the text extraction.
  # If the Document was not originally uploaded, but was passed as a remote URL
  # instead, download it first, convert it to a PDF ... then go to town.
  def split
    if options['url']
      file = File.basename(options['url'])
      File.open(file, 'wb') do |f|
        url = URI.parse(options['url'])
        http = Net::HTTP.new(url.host, url.port)
        (http.use_ssl = true) if url.port == 443
        req = Net::HTTP::Get.new(url.request_uri)
        http.request(req) do |res|
          res.read_body do |seg|
            f << seg
            sleep 0.005 # To allow the buffer to fill (more).
          end
        end
      end
      DC::Store::AssetStore.new.save_original(document, file )
    else
      file = File.basename document.original_file_path
      File.open(file, 'wb'){ |f| f << DC::Store::AssetStore.new.read_original(document) }
    end
    
    build_pages = (document.page_count == 0 or options['rebuild'])

    # Calculate the file hash for the document's original_file so that duplicates can be found
    data = File.open(file, 'rb').read
    attributes = {
      file_size: data.bytesize,
      file_hash: Digest::SHA1.hexdigest(data)
    }
    document.update_attributes(attributes)

    if duplicate = document.duplicates.first
      Rails.logger.info "Duplicate found, copying pdf"
      asset_store.copy_pdf( duplicate, document, access )
      document.update_attributes(page_count: duplicate.page_count) if build_pages
    else
      Rails.logger.info "Building PDF"
      File.open(file, 'r') do |f|
        DC::Import::PDFWrangler.new.ensure_pdf(f, file) do |path|
          document.update_attributes(page_count: Docsplit.extract_length(file)) if build_pages
          DC::Store::AssetStore.new.save_pdf(document, path, access)
        end
      end
    end
    
    create_pages! if build_pages
    
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
      File.open(@pdf, 'wb') {|f| f.write(pdf_contents) }
      case input['task']
      when 'text'   then process_text
      when 'images' then process_images
      end
    rescue Exception => e
      LifecycleMailer.exception_notification(e,options).deliver_now
      raise e
    end
    document.id
  end

  # When both sides are done, update the document to mark it as finished.
  def merge
    document.update_attributes :access => access
    email_on_complete
    super
  end

  def process_images
    if duplicate = document.duplicates.first
      @page_aspect_ratios = duplicate.pages.order(:page_number).pluck(:aspect_ratio).map{ |n| n.nil? ? 0 : n }
      asset_store.copy_images( duplicate, document, access )
    else
      Docsplit.extract_images(@pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :rolling => true, :output => 'images')
      
      page_image_paths = Dir['images/700x/*.gif']
      @page_aspect_ratios = page_image_paths.map do |image_path|
        cmd = %(gm identify #{image_path} | egrep -o "[[:digit:]]+x[[:digit:]]+")
        width, height = `#{cmd}`.split("x").map(&:to_f)
        width / height
      end
      page_count = page_image_paths.length
      page_count.times do |i|
        number = i + 1
        image  = "#{document.slug}_#{number}.gif"
        DC::Import::Utils.save_page_images(asset_store, document, number, image, access)
      end
    end
    save_page_aspect_ratios!
  end

  def process_text
    @pages = []
    if (duplicate = document.duplicates.first) and !options['force_ocr']
      asset_store.copy_text( duplicate, document, access )
      Docsplit.extract_length(@pdf).times do |i|
        page_number = i + 1
        text = asset_store.read document.page_text_path(page_number)
        queue_page_text(text, page_number)
      end
    else
      begin
        opts = {:pages => 'all', :output => 'text', :language => DC::Language.ocr_name(document.language)}
        opts[:ocr] = true if options['force_ocr']
        opts[:clean] = false unless opts[:language] == 'eng'
        Docsplit.extract_text(@pdf, opts)
      rescue Exception => e
        LifecycleMailer.exception_notification(e, options).deliver_now
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
    end
    save_page_text!

    document.page_count = @pages.length
    Page.refresh_page_map(document)
    EntityDate.reset(document)
    document.save!
    pages = document.reload.pages.order(:page_number)
    Sunspot.index pages
    Sunspot.commit
    if ! options['secure'] && DC::Language::SUPPORTED.include?(document.language)
      text = pages.map(&:text).join('')
      DC::Import::EntityExtractor.new.extract(document, text)
    end
    document.upload_text_assets(pages, access)
    document.id
  end


  private

  def queue_page_text(text, page_number)
    @pages.push({:text => text, :number => page_number})
  end
  
  def create_pages!
    rows = (1..document.page_count).map do |page_number|
      "(#{document.organization_id}, #{document.account_id}, #{document.id}, #{access}, #{page_number}, '')"
    end
    Page.connection.execute "insert into pages (organization_id, account_id, document_id, access, page_number, text) values #{rows.join(",\n")};"
  end

  def save_page_text!
    rows = @pages.map do |page|
      "(#{document.organization_id}, #{document.account_id}, #{document.id}, #{access}, #{page[:number]}, '#{PGconn.escape(DC::Search.clean_text(page[:text]))}')"
    end
    
    page_texts = @pages.map{ |page| DC::Search.clean_text(page[:text]) }
    ids        = document.pages.order(:page_number).pluck(:id)
    
    query_template = <<-QUERY
    UPDATE pages 
      SET text = input.text
      FROM (SELECT unnest(ARRAY[?]) as id, unnest(ARRAY[?]) as text) AS input
      WHERE pages.id = input.id::int
    QUERY
    query = Page.send(:replace_bind_variables, query_template, [ids, page_texts])
    Page.connection.execute(query)
  end
  
  def save_page_aspect_ratios!
    ids = document.pages.order(:page_number).pluck(:id)
    
    query_template = <<-QUERY
    UPDATE pages 
      SET aspect_ratio = input.aspect_ratio
      FROM (SELECT unnest(ARRAY[?]) as id, unnest(ARRAY[?]) as aspect_ratio) AS input
      WHERE pages.id = input.id::int
    QUERY
    query = Page.send(:replace_bind_variables, query_template, [ids, @page_aspect_ratios])
    Page.connection.execute(query)
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
      LifecycleMailer.documents_finished_processing(document.account, count).deliver_now
    end
  end
  
  def ocr_language(two_letter)
    DC::Language::ALPHA3[two_letter] || 'eng'
  end

end
