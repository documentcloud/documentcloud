require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_mod_base'
require 'fileutils'

class RedactPages < DocumentModBase

  # The zoom ratio at which we'll be drawing redactions.
  ENLARGEMENT = 1000.0 / 700.0

  def process
    begin
      prepare_pdf
      redact
    rescue Exception => e
      fail_document
      LifecycleMailer.deliver_exception_notification(e, options)
      raise e
    end
    document.id
  end


  private

  def redact
    Docsplit.extract_pages @pdf
    FileUtils.rm @pdf
    redactions_by_page = options['redactions'].group_by {|r| r['page'] }
    redactions_by_page.each {|page, redactions| redact_page page, redactions }
    document.reindex_all! access
  end

  def redact_page(page, redactions)
    page_pdf_path     = "#{document.slug}_#{page}.pdf"
    page_image_path   = "#{document.slug}_#{page}.gif"
    File.open(page_image_path, 'w+') do |f|
      f.write(asset_store.read(document.page_image_path(page, 'large')))
    end
    rectangles = redactions.map { |redaction|
      pos = redaction['location'].split(/,\s*/).map {|px| (px.to_i * ENLARGEMENT).round }
      gm_coords = [pos[3], pos[0], pos[1], pos[2]].join(',')
      "rectangle #{gm_coords}"
    }.join(' ')
    `gm mogrify #{page_image_path} -fill black -draw "#{rectangles}" #{page_image_path}`
    asset_store.save_page_images(document, page,
      {'large' => page_image_path},
      access
    )
  end

end
