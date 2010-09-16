require File.dirname(__FILE__) + '/support/setup'

class DocumentRemovePages < CloudCrowd::Action
  
  def process
    begin
      @pdf = document.slug + '.pdf'
      File.open(@pdf, 'w+') {|f| f.write(asset_store.read_pdf(document)) }
      remove_page options['pages']
      FileUtils.rm @pdf
      FileUtils.mv @pdf + '_temp', @pdf
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    document.id
  end
  
  def merge
    document.update_attributes :access => access
    document.id
  end
  
  private
  
  def remove_page(delete_pages)
    # Which pages to keep
    delete_pages.map! {|p| p.to_i }
    keep_pages = ((1..document.page_count).to_a - delete_pages)
    
    # Rename pages with pdftk, keeping only unremoved pages
    cmd = "pdftk #{@pdf} cat #{keep_pages.join(' ')} output #{document.slug}.pdf_temp"
    `#{cmd}`
    
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
      asset_store.save_page_images(document, i, sizes, access)
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
        Page.connection.execute "UPDATE pages SET start_offset = #{start_offset}, end_offset = #{end_offset} WHERE document_id = #{document.id} AND page_number = #{p};"
      end
    end
    
    # Delete old page texts that are no longer in the document.
    delete_pages.each do |p|
      Page.connection.execute "DELETE FROM pages WHERE document_id = #{document.id} AND page_number = #{p}"
    end
    
    # Update page numbers to compact down deleted pages
    keep_pages.each_with_index do |p, i|
      Page.connection.execute "UPDATE pages SET page_number = #{i+1} WHERE document_id = #{document.id} AND page_number = #{p};"
    end
    
    document.page_count = keep_pages.length
    document.access = access
    text = Page.find_all_by_document_id(235).inject('') {|m, p| m + ' ' + p.text }
    document.full_text.update_attributes({:text => text})
    Page.refresh_page_map(document)
    EntityDate.refresh(document)
    document.save!
    pages = document.reload.pages
    Sunspot.index pages
    Sunspot.commit
    # DC::Import::EntityExtractor.new.extract(document)
    upload_text_assets(pages)    
  end
  
  def upload_text_assets(pages)
    asset_store.save_full_text(document, access)
    pages.each do |page|
      asset_store.save_page_text(document, page.page_number, page.text, access)
    end
  end
  
  def document
    return @document if @document
    ActiveRecord::Base.establish_connection
    @document = Document.find(options['id'])
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end
  
  def access
    options['access'] || DC::Access::PRIVATE
  end
  
end