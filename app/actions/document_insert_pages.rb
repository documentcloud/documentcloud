require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/document_mod_base'
require 'fileutils'

class DocumentInsertPages < DocumentModBase

  def process
    begin
      prepare_pdf
      process_concat options['insert_page_at'], options['pdfs_count']
      move_annotations
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    ensure
      FileUtils.rm @pdf if File.exists? @pdf
    end
    
    # For now, just reimport the entire document.
    # TODO: Only process new images/text from the new pages.
    document.queue_import(options['access'])
  end
  
  def process_concat(insert_page_at, pdfs_count)
    letters = 'abcdefghijklmnopqrstuvwxyz'.upcase.split('')
    pdf_names = {}
    (1..pdfs_count).to_a.each do |n|
      letter = letters[n%26]
      path = File.join(document.path, 'inserts', "#{n.to_s}.pdf")
      File.open("#{n.to_s}.pdf", 'w+') {|f| f.write(asset_store.read(path)) }
      pdf_names[letter] = "#{letter}=#{n.to_s}.pdf"
    end
    
    cmd = "pdftk A=#{@pdf} #{pdf_names.values.join(' ')} cat A1-#{insert_page_at} #{pdf_names.keys.join(' ')} A#{insert_page_at}-end output #{document.slug}.pdf_temp"
    `#{cmd}`
    
    asset_store.save_pdf(document, "#{document.slug}.pdf_temp")
    FileUtils.rm @pdf + '_temp'
    (1..pdfs_count).to_a.each do |n|
      FileUtils.rm "#{n.to_s}.pdf"
    end
    asset_store.delete_insert_pdfs(document)
  end

  def move_annotations
    
  end
end