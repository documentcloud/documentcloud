require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_action'
require 'fileutils'

class RedactPages < DocumentAction

  # The zoom ratio at which we'll be drawing redactions.
  LARGE_FACTOR      = 1000.0 / 700.0
  # ORIGINAL_FACTOR = 1700.0 / 700.0
  REDACTION_COLORS  = {
    'black' => '#000000',
    'red'   => '#880000'
  }
  MAX_PER_PAGE      = 25

  SIZE_EXTRACTOR    = /(\d+)x(\d+)/

  GM_ARGS = '-limit memory 256MiB -limit map 512MiB'

  def process
    begin
      prepare_pdf
      redact
    rescue Exception => e
      fail_document
      LifecycleMailer.exception_notification(e,options).deliver_now
      raise e
    end
    document.id
  end


  private

  def redact
    Docsplit.extract_pages @pdf
    FileUtils.rm @pdf
    redactions_by_page = options['redactions'].group_by {|r| r['page'].to_i }
    redactions_by_page.each {|page, redactions| redact_page page, redactions }
    rebuild_pdf
    document.reindex_all! access
  end

  def redact_page(page, redactions)
    base  = "#{document.slug}_#{page}"
    color = REDACTION_COLORS[options['color']]

    # Make the list of image file paths.
    images = {}
    Page::IMAGE_SIZES.each do |size, geometry|
      images[size] = "#{base}_#{size}.gif"
    end

    # Get the large version of the page image.
    page_pdf_path  = "#{base}.pdf"
    page_tiff_path = "#{base}.tif"
    File.open(images['large'], 'wb') do |f|
      f.write(asset_store.read(document.page_image_path(page, 'large')))
    end

    # Draw red rectangular redactions on both versions.
    coords = redactions.map do |redaction|
      pos = redaction['location'].split(/,\s*/)
      [pos[3], pos[0], pos[1], pos[2]]
    end
    coords.each_slice(MAX_PER_PAGE) do |coords_slice|
      large_coords    = coords_slice.map {|list| 'rectangle ' + list.map {|px| (px.to_i * LARGE_FACTOR).round }.join(',') }.join(' ')
      `gm mogrify #{GM_ARGS} #{images['large']} -fill "#{color}" -draw "#{large_coords}" #{images['large']} 2>&1`
    end

    # Downsize the large image to all smaller image sizes.
    previous = nil
    Page::IMAGE_SIZES.each do |size, geometry|
      if size != 'large'
        FileUtils.cp previous, images[size]
        `gm mogrify #{GM_ARGS} -density 150 -resize #{geometry} #{images[size]} 2>&1`
      end
      previous = images[size]
    end

    # Save the redacted images to our asset store.
    asset_store.save_page_images(document, page, images, access)

    # Write out the new redacted pdf page, and tiff version for OCR.
    `gm convert #{GM_ARGS} #{images['large']} #{page_pdf_path} 2>&1`
    `gm convert #{GM_ARGS} -colorspace GRAY #{images['large']} #{page_tiff_path} 2>&1`

    # OCR the large version of the image.
    `tesseract #{page_tiff_path} #{base} -l eng 2>&1`
    text = Docsplit.clean_text(DC::Import::Utils.read_ascii("#{base}.txt"))

    document.pages.find_by_page_number(page).update_attributes :text => text
  end

  # Create the new PDF for the full document, and save it to the asset store.
  # When complete, calculate the new file_hash for the document
  def rebuild_pdf
    page_paths = (1..document.page_count).map {|i| "#{document.slug}_#{i}.pdf" }
    #`pdftk #{page_paths.join(' ')} cat output #{@pdf}`
    `pdftailor stitch --output #{@pdf} #{page_paths.join(' ')} 2>&1`

    if File.exists? @pdf
      asset_store.save_pdf(document, @pdf, access)
      File.open( @pdf,'r') do | fh |
        document.update_file_metadata( fh.read )
      end
    end
  end

end
