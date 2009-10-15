RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RACK_ENV']

gem 'documentcloud-calais'

require 'digest/sha1'
require 'faker'
require 'activesupport'
require 'calais'
require 'right_aws'
require 'rufus-tokyo'
require 'rufus/tokyo/tyrant'
require 'config/initializers/configuration'
require 'app/models/document'
require 'app/models/metadatum'
require 'app/models/occurrence'
require 'lib/dc/store/tokyo_tyrant_table'
require 'lib/dc/store/metadata_store'
require 'lib/dc/store/entry_store'
require 'lib/dc/import/metadata_extractor'
require 'lib/dc/import/calais_fetcher'
require 'lib/dc/import/image_extractor'
require 'lib/dc/import/text_extractor'

# DocumentCloud import produces full text, RDF from OpenCalais, and thumbnails
# from a PDF document. The calling DocumentCloud instance is responsible for
# downloading and ingesting these resources.
class DocumentImport < CloudCrowd::Action
  
  def process
    begin
      text_path, title = extract_full_text_and_title
      thumb_path, small_thumb_path = *generate_thumbnails
      rdf_path = fetch_rdf_from_calais
      doc = Document.new({
        :organization_id      => options['organization_id'],
        :account_id           => options['account_id'],
        :access               => options['access'] || DC::Access::PUBLIC,
        :full_text            => @text,
        :rdf                  => @rdf
      })
      DC::Import::MetadataExtractor.new.extract_metadata(doc)
      DC::Store::MetadataStore.new.save_document(doc) 
      return {
        'title'               => options['title'] || title,
        'source'              => options['source'],
        'organization_id'     => options['organization_id'],
        'account_id'          => options['account_id'],
        'access'              => options['access'],
        'pdf_url'             => input,
        'full_text_url'       => save(text_path),
        'rdf_url'             => save(rdf_path),
        'thumbnail_url'       => save(thumb_path),
        'small_thumbnail_url' => save(small_thumb_path)
      }
    rescue Exception => e
      puts e.message
      puts e.backtrace
      raise e
    end
  end
  
  def extract_full_text_and_title
    ex = DC::Import::TextExtractor.new(input_path)
    @text = ex.get_text
    path = "#{work_directory}/#{file_name}.txt"
    File.open(path, 'w+') {|f| f.write(@text) }
    title = ex.get_title || File.basename(input)
    [path, title]
  end
  
  def generate_thumbnails
    image_ex = DC::Import::ImageExtractor.new(input_path)
    image_ex.get_thumbnails
    [image_ex.thumbnail_path, image_ex.small_thumbnail_path]
  end
  
  def fetch_rdf_from_calais
    path = "#{work_directory}/#{file_name}.rdf"
    begin
      @rdf = DC::Import::CalaisFetcher.new.fetch_rdf(@text)
      resp = Calais::Response.new(@rdf)
    rescue Calais::Error => e
      puts e.message
      puts 'waiting 10 seconds'
      sleep 10
      retry
    end
    File.open(path, 'w+') {|f| f.write(@rdf) }
    path
  end
  
end