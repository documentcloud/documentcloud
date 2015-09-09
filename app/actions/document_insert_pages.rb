require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_action'
require 'fileutils'

class DocumentInsertPages < DocumentAction

  def process
    @old_page_count    = document.page_count
    @pdfs_count        = options['pdfs_count'].to_i
    @insert_page_at    = options['insert_page_at'].to_i
    @insert_page_count = 0
    @insert_pdfs       = (1..@pdfs_count).map {|n| "#{n}.pdf" }
    begin
      prepare_pdf
      process_concat
      add_pages
      document.reorder_pages(new_page_order, access)
    rescue Exception => e
      fail_document
      LifecycleMailer.exception_notification(e,options).deliver_now
      raise e
    end
    document.id
  end

  def add_pages
    @insert_pdfs.each do |pdf|
      pdf_name       = File.basename(pdf, '.pdf')
      pdf_page_count = Docsplit.extract_length(pdf)

      # Upload images + text.
      Docsplit.extract_images(pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :rolling => true, :output => 'images')
      Docsplit.extract_text(pdf, :pages => 'all', :output => 'text', :language => DC::Language.ocr_name(document.language))
      pdf_page_count.times do |i|
        number          = i + 1
        image_name      = "#{pdf_name}_#{number}.gif"
        text_name       = "text/#{pdf_name}_#{number}.txt"
        insert_position = @old_page_count + @insert_page_count + number
        text            = DC::Import::Utils.read_ascii(text_name)
        DC::Import::Utils.save_page_images(asset_store, document, insert_position, image_name, access)
        document.pages.create(:page_number => insert_position, :text => text)
        Page.refresh_page_map document
      end

      # Remove local files from previous iteration.
      FileUtils.rm_r('images')
      FileUtils.rm_r('text')
      @insert_page_count += pdf_page_count
    end

    # We're done. Set the new page count.
    document.update_attributes(:page_count => @old_page_count + @insert_page_count)
  end

  # Calculate the new page order (array of page numbers).
  def new_page_order
    return @new_page_order if @new_page_order
    current_page_order = (1..@old_page_count).to_a
    new_pages_order    = ((@old_page_count + 1)..(@old_page_count + @insert_page_count)).to_a
    @new_pages_order   = current_page_order.insert(@insert_page_at, *new_pages_order)
  end

  # Rebuilds the PDF from the burst apart pages in the correct order. Saves
  # images and text from the to-be-inserted PDFs to the local disk.
  def process_concat
    letters = ('A'..'Z').to_a
    pdf_names = {}
    @insert_pdfs.each_with_index do |pdf, i|
      letter = letters[(i + 1) % 26]
      path = File.join(document.path, 'inserts', pdf)
      File.open(pdf, 'wb') {|f| f.write(asset_store.read(path)) }
      pdf_names[letter] = "#{letter}=#{pdf}"
    end

    cmd = "pdftk A=#{@pdf} #{pdf_names.values.join(' ')} cat A #{pdf_names.keys.join(' ')} output #{document.slug}.pdf_temp"
    `#{cmd} 2>&1`

    asset_store.save_pdf(document, "#{document.slug}.pdf_temp", access)
    asset_store.delete_insert_pdfs(document)
  end

end
