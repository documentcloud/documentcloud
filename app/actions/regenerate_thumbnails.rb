require File.dirname(__FILE__) + '/support/setup'

class RegenerateThumbnails < CloudCrowd::Action

  def process
    @pdf = document.slug + '.pdf'
    File.open(@pdf, 'wb') {|f| f.write(asset_store.read_pdf(document)) }
    Docsplit.extract_images(@pdf, :format => :gif, :size => Page::IMAGE_SIZES['thumbnail'], :output => 'images')
    puts "Regenerating Thumbnails: #{document.title}"
    document.page_count.times do |i|
      image = "images/#{document.slug}_#{i + 1}.gif"
      asset_store.save_page_images(document, i + 1, {'thumbnail'  => image}, document.access)
    end
    input
  end


  private

  def document
    return @document if @document
    ActiveRecord::Base.establish_connection
    @document = Document.find(input)
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

end
