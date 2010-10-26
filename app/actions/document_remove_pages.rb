require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_mod_base'
require 'fileutils'

class DocumentRemovePages < DocumentModBase

  def process
    begin
      prepare_pdf
      @insert_after_remove = options['replace_pages_start'] && options['insert_document_count']
      remove_page options['pages']
      if @insert_after_remove
        # -1 because we are inserting BEFORE where the pages were removed.
        document.insert_documents(options['replace_pages_start']-1,
                                  options['insert_document_count'],
                                  options['access'])
      end
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    document.id
  end

  private

  def remove_page(delete_pages)
    # Which pages to keep
    delete_pages.map! {|p| p.to_i }.sort
    keep_pages = ((1..document.page_count).to_a - delete_pages)

    # Rename pages with pdftk, keeping only unremoved pages
    cmd = "pdftk #{@pdf} cat #{keep_pages.join(' ')} output #{document.slug}.pdf_temp"
    `#{cmd}`
    asset_store.save_pdf(document, "#{document.slug}.pdf_temp")

    # Pull images from S3, delete old images, then upload renamed images
    keep_pages.each_with_index do |p, i|
      sizes = {}
      Page::IMAGE_SIZES.keys.each do |size|
        page = document.page_image_path(p, size)
        new_file = "#{document.slug}-p#{i+1}-#{size}.gif"
        sizes[size] = new_file
        File.open(new_file, 'w+') do |f|
          f.write(asset_store.read(page))
        end
      end
      asset_store.save_page_images(document, i+1, sizes, access)
      # TODO: Delete orphaned page images on S3
    end

    # Update page offsets for text
    (1..document.page_count).each do |p|
      this_page = Page.find_by_document_id_and_page_number(document.id, p)
      previous_page = Page.find_by_document_id_and_page_number(document.id, p-1)
      end_offset = 0
      start_offset = 0
      if this_page
        if delete_pages.include? p
          start_offset = previous_page ? previous_page.end_offset : 0
          end_offset = previous_page ? previous_page.end_offset : 0
        else
          start_offset = previous_page ? previous_page.end_offset + 1 : 0
          end_offset = (this_page.end_offset - this_page.start_offset) + start_offset
        end
        this_page.update_attributes :start_offset => start_offset, :end_offset => end_offset
      end
    end

    # Delete old pages and annotations that are no longer in the document.
    delete_pages.each do |p|
      where = "document_id = #{document.id} AND page_number = #{p}"
      Page.destroy_all where
      Annotation.destroy_all where
    end

    # Update page numbers to compact down deleted pages.
    keep_pages.each_with_index do |old_number, i|
      new_number = i + 1
      set = "SET page_number = #{new_number} WHERE document_id = #{document.id} AND page_number = #{old_number};"
      Page.connection.execute "UPDATE pages #{set}"
      Annotation.connection.execute "UPDATE annotations #{set}"
    end

    # Compact, remove, and/or move all sections
    sections = Section.find_all_by_document_id(document.id)
    sections.each do |section|
      delete_pages.reverse.each do |delete_page|
        section.start_page -= 1 if section.start_page > delete_page
        section.end_page -= 1   if section.end_page >= delete_page
      end
      section.save    if section.changed?
      section.destroy if section.impossible?
    end

    document.page_count = keep_pages.length
    document.save!

    if not @insert_after_remove
      reindex_all!
    end
  end

end