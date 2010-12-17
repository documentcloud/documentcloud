# Initial DB import:
# mysql -u root -p docviewer_prod < docviewer_prod-20101213.sql

namespace :import do

  desc "Import the NYTimes' Document Viewer database"
  task :nyt, {:needs => :environment} do
    require 'mysql2'
    require 'tmpdir'
    require 'iconv'
    client = Mysql2::Client.new :host => 'localhost', :username => 'root', :database => 'docviewer_prod'
    # NB: Resuming after failed connection.
    docs   = client.query 'select * from documents where (id = 292 or id >= 340)'
    docs.each do |doc|
      begin
        client.reset!
        import_document(client, doc)
      rescue Exception => e
        puts e
        sleep 1
      end
    end
  end

end


# Import a single document (Mysql2 hash of attributes).
def import_document(client, record)

  ref = "#{record['id']} - #{record['title']}"
  puts "#{ref} -- starting..."

  asset_store = DC::Store::AssetStore.new
  access      = record['published_at'] ? DC::Access::PUBLIC : DC::Access::ORGANIZATION

  doc = Document.create({
    :organization_id  => 20,    # NYTimes
    :account_id       => 1159,  # newsdocs@nytimes.com
    :access           => DC::Access::PENDING,
    :title            => record['title'],
    :slug             => record['slug'],
    :source           => record['creator'].blank? ? nil : record['creator'],
    :description      => record['description'],
    :created_at       => record['created_at'],
    :updated_at       => record['updated_at'],
    :related_article  => record['story_url']
  })
  doc.remote_url = "http://documents.nytimes.com/#{doc.canonical_id}"

  puts "#{ref} -- importing pages..."

  page_records = client.query "select * from pages where document_id = #{record['id']} order by page_number asc"
  pages = []
  page_records.each do |page_record|
    text = Iconv.iconv('ascii//translit//ignore', 'utf-8', page_record['contents']).first
    pages.push doc.pages.create({
      :page_number => page_record['page_number'],
      :text        => text,
      :access      => access
    })
  end
  puts "#{ref} -- #{pages.length} pages..."
  doc.page_count = pages.length
  doc.full_text  = FullText.create!(:text => pages.map{|p| p[:text] }.join(''), :document => doc, :access => access)

  if doc.page_count <= 0
    puts "#{ref} -- zero pages, aborting..."
    doc.destroy
    return
  end

  puts "#{ref} -- refreshing page map, extracting dates, indexing..."

  Page.refresh_page_map doc
  EntityDate.refresh doc
  doc.save!
  pages = doc.reload.pages
  Sunspot.index pages

  puts "#{ref} -- extracting entities from Calais, uploading text to S3..."
  DC::Import::EntityExtractor.new.extract(doc)
  doc.upload_text_assets(pages)
  sql = ["access = #{access}", "document_id = #{doc.id}"]
  Entity.update_all(*sql)
  EntityDate.update_all(*sql)

  puts "#{ref} -- importing sections..."

  sections = client.query "select * from chapters where document_id = #{record['id']} order by start_page asc"
  sections.each do |section_record|
    doc.sections.create({
      :title        => section_record['title'],
      :page_number  => section_record['start_page'],
      :access       => access
    })
  end

  puts "#{ref} -- importing notes..."

  notes = client.query "select * from notes where document_id = #{record['id']} order by page_number asc"
  notes.each do |nr|
    coords = [nr['y0'], nr['x1'], nr['y1'], nr['x0']].join(',')
    doc.annotations.create({
      :page_number  => nr['page_number'],
      :access       => DC::Access::PUBLIC,
      :title        => nr['title'],
      :content      => nr['description'],
      :location     => nr['layer_type'] == 'region' ? coords : nil
    })
  end

  puts "#{ref} -- grabbing PDF, uploading to S3..."

  Dir.mktmpdir do |tmpdir|
    pdf       = File.join(tmpdir, 'temp.pdf')
    image_dir = File.join(tmpdir, 'images')
    s3_url    = "http://s3.amazonaws.com/nytdocs/docs/#{record['id']}/#{record['id']}.pdf"
    puts `curl #{s3_url} > #{pdf}`
    asset_store.save_pdf(doc, pdf, access)

    puts "#{ref} -- processing images..."

    Docsplit.extract_images(pdf, :format => :gif, :size => Page::IMAGE_SIZES.values, :rolling => true, :output => image_dir)
    doc.page_count.times do |i|
      number = i + 1
      image  = "temp_#{number}.gif"
      asset_store.save_page_images(doc, number,
        {'normal'     => "#{image_dir}/700x/#{image}",
         'small'      => "#{image_dir}/180x/#{image}",
         'large'      => "#{image_dir}/1000x/#{image}",
         'small'      => "#{image_dir}/180x/#{image}",
         'thumbnail'  => "#{image_dir}/60x75!/#{image}"},
        access
      )
    end
  end

  doc.access = access
  doc.save
  puts "#{ref} -- finished."

end