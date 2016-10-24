require File.dirname(__FILE__) + '/support/setup'
=begin

This is a demonstrative spike to add automated Tabula processing to DocumentCloud.

CloudCrowd and DocumentCloud together provide a framework for fetching and storing
documents, iterating over pages, and a blank canvas into which authors can
write processing jobs.

This initial spike is intended merely to be a proof of concept for future delineation
of API responsibilities between DocumentCloud and a processing job author.

Also, to process documents through tabula w/o any additional input from users (yet).

You can test it in the Rails console like this:
job = ExtractTables.new(CloudCrowd::PROCESSING, ['25'], {'id' =>'25', 'job_id'=>1, 'work_unit_id' => 1, 'attempts'=> 0}, CloudCrowd::AssetStore.new); job.process

=end

class ExtractTables < CloudCrowd::Action
  def process
    # fetch pdf
    pdf_name = File.basename(document.pdf_path)
    pdf_contents = asset_store.read_pdf document
    File.open(pdf_name, 'wb') {|f| f.write(pdf_contents) }
    File.open(pdf_name) do |pdf|
      tabula_jar = '/usr/local/lib/tabula-0.8.0-jar-with-dependencies.jar'
      raise RuntimeError, "Can't find Tabula jar file at #{tabula_jar}" unless File.exists? tabula_jar
      # iterate from 1 to page_count and with each page
      (1..document.page_count).each do |page_number|
        cmd = "java -jar #{tabula_jar} #{pdf_name} --spreadsheet --pages #{page_number}"
        # produce a spreadsheet for page
        maybe_table = `#{cmd}`
        # store spreadsheet
        store_spreadsheet(page_number, maybe_table)
      end
    end
    document.id
  end
  
  private
  def document
    @document ||= Document.find(options['id'])
  end
  
  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end
  
  def store_spreadsheet(page_number, data)
    # replace this with a less ridiculous API.
    asset_store.save_tabula_page(document, page_number, data)
  end
end