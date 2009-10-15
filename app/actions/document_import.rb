RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RACK_ENV']

# Makes you pine for Rails autoload, dunnit?

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
require 'lib/dc/store/s3_store'
require 'lib/dc/store/file_system_store'
require 'lib/dc/store/asset_store'
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
      title                         = extract_full_text_and_title
      thumb_path, small_thumb_path  = *generate_thumbnails
      calais_response               = fetch_rdf_from_calais
      doc = Document.new({
        :title                => options['title'] || title,
        :source               => options['source'] || Faker::Company.name,
        :organization_id      => options['organization_id'],
        :account_id           => options['account_id'],
        :access               => options['access'] || DC::Access::PUBLIC,
        :pdf                  => input_path,
        :full_text            => @text,
        :rdf                  => @rdf,
        :thumbnail            => thumb_path,
        :small_thumbnail      => small_thumb_path
      })
      if calais_response
        DC::Import::MetadataExtractor.new.extract_metadata(doc, calais_response)
      else
        doc.metadata = []
      end
      doc.save
      return doc.id
    rescue Exception => e
      puts e.class.to_s
      puts e.message
      puts e.backtrace
      raise e
    end
  end
  
  def extract_full_text_and_title
    ex = DC::Import::TextExtractor.new(input_path)
    @text = ex.get_text
    ex.get_title || File.basename(input)
  end
  
  def generate_thumbnails
    image_ex = DC::Import::ImageExtractor.new(input_path)
    image_ex.get_thumbnails
    [image_ex.thumbnail_path, image_ex.small_thumbnail_path]
  end
  
  # TODO: clean up the errors that we want to retry only -- add calais exception
  # classes to the gem.
  def fetch_rdf_from_calais
    path = "#{work_directory}/#{file_name}.rdf"
    begin
      @rdf = DC::Import::CalaisFetcher.new.fetch_rdf(@text)
      return Calais::Response.new(@rdf)
    rescue Calais::Error => e
      puts e.message
      return @rdf = nil if e.message == 'Calais continues to expand its list of supported languages, but does not yet support your submitted content.'
      puts 'waiting 10 seconds'
      sleep 10
      retry
    end
  end
  
end