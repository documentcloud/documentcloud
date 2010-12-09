require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_mod_base'
require 'fileutils'

class DocumentInsertPages < DocumentModBase

  def process
    @pdfs_count        = options['pdfs_count'].to_i
    @insert_page_at    = options['insert_page_at'].to_i
    @insert_page_count = 0
    begin
      prepare_pdf
      process_concat
      move_annotations
      move_sections
    rescue Exception => e
      fail_document
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end

    # For now, just reimport the entire document.
    # TODO: Only process new images/text from the new pages.
    document.queue_import access

    document.id
  end

  # Move the annotations forwards in their page references.
  def move_annotations
    annotations = Annotation.all(:conditions =>
      ["document_id = ? and page_number > ?", document.id, @insert_page_at]
    )
    annotations.each do |annotation|
      annotation.page_number += @insert_page_count
      annotation.save
    end
  end

  # Move sections forwards, if the inserted pages affect them.
  def move_sections
    sections = Section.find_all_by_document_id(document.id)
    sections.each do |section|
      section.start_page += @insert_page_count if section.start_page >= @insert_page_at
      section.end_page   += @insert_page_count if section.end_page   >= @insert_page_at
      section.save if section.changed?
    end
  end

  # Rebuilds the PDF from the burst apart pages in the correct order.
  def process_concat
    letters = ('A'..'Z').to_a
    pdf_names = {}
    (1..@pdfs_count).each do |n|
      letter = letters[n%26]
      path = File.join(document.path, 'inserts', "#{n.to_s}.pdf")
      File.open("#{n.to_s}.pdf", 'w+') {|f| f.write(asset_store.read(path)) }
      pdf_names[letter] = "#{letter}=#{n.to_s}.pdf"
    end

    start_part  = @insert_page_at <= 0 ? '' : "A1-#{@insert_page_at}"
    end_part    = @insert_page_at < document.page_count ? "A#{@insert_page_at + 1}-end" : ''
    cmd = "pdftk A=#{@pdf} #{pdf_names.values.join(' ')} cat #{start_part} #{pdf_names.keys.join(' ')} #{end_part} output #{document.slug}.pdf_temp"
    `#{cmd}`

    asset_store.save_pdf(document, "#{document.slug}.pdf_temp", access)

    (1..@pdfs_count).to_a.each do |n|
      pdf_path = "#{n.to_s}.pdf"
      @insert_page_count += Docsplit.extract_length(pdf_path)
    end
    asset_store.delete_insert_pdfs(document)
  end

end