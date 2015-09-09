require File.dirname(__FILE__) + '/support/setup'
require File.dirname(__FILE__) + '/support/document_action'
require 'fileutils'

class DocumentRemovePages < DocumentAction

  def process
    begin
      prepare_pdf
      @insert_after_remove = options['replace_pages_start'] && options['insert_document_count']
      remove_pages options['pages']
      if @insert_after_remove
        # -1 because we are inserting BEFORE where the pages were removed.
        document.insert_documents(options['replace_pages_start']-1,
                                  options['insert_document_count'],
                                  options['access'])
      end

    rescue Exception => e
      fail_document
      LifecycleMailer.exception_notification(e,options).deliver_now
      raise e
    end
    document.id
  end

  private

  def remove_pages(delete_pages)
    # Which pages to keep
    total = document.page_count
    delete_pages.sort!
    keep_pages = ((1..total).to_a - delete_pages)
    orphaned_pages = ((total - delete_pages.length + 1)..total)

    # Rename pages with pdftk, keeping only unremoved pages
    tmp_name = "#{document.slug}.pdf_temp"
    cmd = "pdftk #{@pdf} cat #{keep_pages.join(' ')} output #{tmp_name}"
    `#{cmd} 2>&1`
    if File.exists? tmp_name
      asset_store.save_pdf(document, tmp_name)
      File.open(tmp_name,'r') do | fh |
        document.update_file_metadata( fh.read )
      end
    end

    # Pull images from S3, delete old images, then upload renamed images
    keep_pages.each_with_index do |p, i|
      sizes = {}
      Page::IMAGE_SIZES.keys.each do |size|
        page = document.page_image_path(p, size)
        new_file = "#{document.slug}-p#{i+1}-#{size}.gif"
        sizes[size] = new_file
        File.open(new_file, 'wb') do |f|
          f.write(asset_store.read(page))
        end
      end
      asset_store.save_page_images(document, i+1, sizes, access)
    end

    # Update page offsets for text
    (1..document.page_count).each do |p|
      this_page = Page.where(:document_id=>document.id, :page_number=> p).first
      previous_page = Page.where(:document_id=>document.id, :page_number=> p-1).first
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

    # Compact, remove, and/or move all sections.
    sections = Section.where(:document_id=>document.id).order('page_number asc')
    taken_page_numbers = {}
    sections.each do |section|
      delete_pages.reverse.each do |delete_page|
        section.page_number -= 1 if section.page_number >= delete_page
      end
      if taken_page_numbers[section.page_number]
        section.destroy
      else
        section.save if section.changed?
        taken_page_numbers[section.page_number] ||= true
      end
    end

    document.page_count = keep_pages.length
    document.save!

    # Remove orphaned page images and text from S3.
    orphaned_pages.each do |p|
      asset_store.delete_page_images(document, p)
      asset_store.delete_page_text(document, p)
    end

    document.reindex_all!(access) unless @insert_after_remove
  end

end
