class SmallThumbnails < ActiveRecord::Migration
  def self.up
    total_documents = Document.all.count
    Document.all.each_with_index do |doc, i|
      begin
        puts " --> #{i+1}/#{total_documents} Starting: [#{doc.page_count} pages] #{doc.title}"
        asset_store ||= DC::Store::AssetStore.new
        pages = {}
        doc.page_count.times.each do |page|
          pages[page] = "#{page+1}-normal.gif"
          page_path = doc.page_image_path(page+1, 'normal')
          File.open(pages[page], 'w+') do |f|
            f.write(asset_store.read(page_path))
          end
        end

        puts " --> Processing #{doc.page_count} images..."
        cmd = "OMP_NUM_THREADS=2 gm mogrify -limit memory 256MiB -limit map 512MiB -density 150 -resize #{Page::IMAGE_SIZES['small']} -quality 100 -unsharp 0x0.5+0.75 \"*.gif\" 2>&1"
        result = `#{cmd}`

        puts " --> Saving #{doc.page_count} images..."
        pages.each_pair do |i, page|
          asset_store.save_page_images(doc, i + 1,
            {'small' => page},
            doc.access
          )
          File.delete(page)
        end
      rescue
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts " --> ERROR on document id: #{doc.id}"
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      end
    end
  end

  def self.down
  end
end
