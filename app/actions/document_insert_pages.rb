require File.dirname(__FILE__) + '/support/setup'

class DocumentInsertPages < DocumentModBase

  def process
    begin
      prepare_pdf
      process_concat options[:insert_page_at]
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    ensure
      FileUtils.rm @pdf if File.exists? @pdf
    end
    document.access = access
    document.save
    document.id
  end

  
  def process_concat(insert_page_at)
    letters = 'abcdefghijklmnopqrstuvwxyz'.upcase.split('')
    pdfs = 5
    pdf_names = {}
    pdfs.times do |n|
      letter = letters[n/26]+letters[n%26]
      pdf_names[letter] = letter + '=' + n + '.pdf'
    end
    cmd = "pdftk A=#{@pdf} #{insert_pdfs.values.join(' ')} cat A1-#{insert_page_at} #{insert_pdfs.keys.join(' ')} A#{insert_page_at}-end  output #{document.slug}.pdf_temp"
    `#{cmd}`
    asset_store.save_pdf(document, "#{document.slug}.pdf_temp")
    FileUtils.rm @pdf + '_temp'
  end
  
end