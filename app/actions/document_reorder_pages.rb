require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_mod_base'
require 'fileutils'

class DocumentReorderPages < DocumentModBase

  def process
    begin
      prepare_pdf
      if document.assert_page_order(options['page_order'])
        reorder_pages options['page_order']
      else
        raise "Inexplicable page order: #{options.inspect} (#{document.inspect})"
      end
    rescue Exception => e
      fail_document
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    document.id
  end

  private
  
  def reorder_pages(page_order)
    # Rewrite PDF with pdftk, using new page order
    cmd = "pdftk #{@pdf} cat #{page_order.join(' ')} output #{document.slug}.pdf_temp"
    `#{cmd}`
    asset_store.save_pdf(document, "#{document.slug}.pdf_temp") if File.exists? "#{document.slug}.pdf_temp"

    # Pull images from S3, delete old images, then upload renamed images
    reordered_page_images = {}
    page_order.each_with_index do |old_num, i|
      new_num = i + 1
      if old_num != new_num
        reordered_page_images[new_num] = {}
        Page::IMAGE_SIZES.keys.each do |size|
          page = document.page_image_path(old_num, size)
          image_path = reordered_page_images[new_num][size] = "#{document.slug}-p#{new_num}-#{size}.gif"
          File.open(image_path, 'w+') do |f|
            f.write(asset_store.read(page))
          end
        end
      end
    end

    # We have to wait until all pages have been written out locally, or else
    # we'll be clobbering existing pages on S3.
    reordered_page_images.each do |p, image_paths|
      asset_store.save_page_images(document, p, image_paths, access)
    end

    # Update page offsets for text.
    offset = 0
    page_order.each_with_index do |p, i|
      page = Page.find_by_document_id_and_page_number(document.id, p)
      unless page
        LifecycleMailer.deliver_logging_email("Reorder pages", {
          :document_id => document.id, 
          :document => document, 
          :page_count => document.page_count, 
          :page_order => page_order
        })
      end
      page_length = (page.end_offset - page.start_offset)
      page.end_offset = offset + page_length
      page.start_offset = offset
      offset += page_length
      page.page_number = (i+1) + document.page_count
      page.save
    end
    pages = Page.find_all_by_document_id(document.id)
    pages.each do |page|
      page.page_number = page.page_number - document.page_count
      page.save
    end

    # Update annotations.
    annotations = Annotation.find_all_by_document_id(document.id)
    annotations.each do |annotation|
      annotation_index = page_order.index(annotation.page_number)
      if annotation_index
        annotation.page_number = annotation_index + 1
        annotation.save
      else
        annotation.destroy
      end
    end

    # Update sections.
    sections = Section.find_all_by_document_id(document.id)
    sections.each do |section|
      section_index = page_order.index(section.page_number)
      if section_index
        section.page_number = section_index + 1
        section.save
      else
        section.destroy
      end
    end

    document.reindex_all!(access)
  end

end