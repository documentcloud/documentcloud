RAILS_ROOT = File.expand_path(Dir.pwd)
RAILS_ENV = ENV['RAILS_ENV'] = ENV['RACK_ENV']

if CloudCrowd.node?
  require 'rubygems'
  require 'activerecord'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  require 'config/environment'
end

# DocumentCloud import produces full text, RDF from OpenCalais, and thumbnails
# from a PDF document. The calling DocumentCloud instance is responsible for
# downloading and ingesting these resources.
class DocumentImport < CloudCrowd::Action
  
  def process
    begin
      ActiveRecord::Base.establish_connection
      extract_full_text_and_title
      generate_thumbnails
      calais_response = fetch_rdf_from_calais
      doc = Document.new({
        :title                => options['title'] || @title,
        :source               => options['source'] || Faker::Company.name,
        :organization_id      => options['organization_id'],
        :account_id           => options['account_id'],
        :access               => options['access'] || DC::Access::PUBLIC,
        :pdf                  => input_path,
        :rdf                  => @rdf,
        :thumbnail            => @thumb_path,
        :small_thumbnail      => @small_thumb_path
      })
      doc.full_text = FullText.new(:text => @text, :document => doc)
      # TODO: Start splitting pdf into pages.
      doc.pages = [Page.new(:text => @text, :document => doc, :page_number => 1)]
      doc.page_count = doc.pages.length
      if calais_response
        DC::Import::MetadataExtractor.new.extract_metadata(doc, calais_response)
      else
        doc.metadata = []
      end
      doc.save!
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
    @title = ex.get_title || File.basename(input)
  end
  
  def generate_thumbnails
    image_ex = DC::Import::ImageExtractor.new(input_path)
    image_ex.get_thumbnails
    @thumb_path = image_ex.thumbnail_path
    @small_thumb_path = image_ex.small_thumbnail_path
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