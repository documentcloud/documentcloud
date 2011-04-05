require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_mod_base'
require 'fileutils'

class RedactPages < DocumentModBase

  # The zoom ratio at which we'll be drawing redactions.
  ENLARGEMENT = 1000.0 / 700.0

  GM_ARGS = "-density 150 -limit memory 256MiB -limit map 512MiB"

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

    # Make the list of image file paths.
    images = {}
    Page::IMAGE_SIZES.each do |size, geometry|
      images[size] = "#{document.slug}_#{page}_#{size}.gif"
    end

    # Get the large version of the page image.
    page_pdf_path = "#{document.slug}_#{page}.pdf"
    File.open(images['large'], 'w+') do |f|
      f.write(asset_store.read(document.page_image_path(page, 'large')))
    end

    # Draw black rectangular redactions on it.
    rectangles = redactions.map { |redaction|
      pos = redaction['location'].split(/,\s*/).map {|px| (px.to_i * ENLARGEMENT).round }
      gm_coords = [pos[3], pos[0], pos[1], pos[2]].join(',')
      "rectangle #{gm_coords}"
    }.join(' ')
    `gm mogrify #{GM_ARGS} #{images['large']} -fill black -draw "#{rectangles}" #{images['large']} 2>&1`

    # Downsize it to all smaller image sizes.
    previous = nil
    Page::IMAGE_SIZES.each do |size, geometry|
      if size != 'large'
        FileUtils.cp previous, images[size]
        `gm mogrify #{GM_ARGS} -unsharp 0x0.5+0.75 -resize #{geometry} #{images[size]} 2>&1`
      end
      previous = images[size]
    end

    # Save the redacted images to our asset store.
    asset_store.save_page_images(document, page, images, access)

  end

end
