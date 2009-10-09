CALAIS_LICENSE = 'REDACTED'

require "lib/dc/import/calais_fetcher"
require "lib/dc/import/image_extractor"
require "lib/dc/import/text_extractor"

# DocumentCloud import produces full text, RDF from OpenCalais, and thumbnails
# from a PDF document. The calling DocumentCloud instance is responsible for
# downloading and ingesting these resources.
class DocumentImport < CloudCrowd::Action
  
  def process
    text_path, title = extract_full_text_and_title
    thumb_path, small_thumb_path = *generate_thumbnails
    rdf_path = fetch_rdf_from_calais
    {
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
    rdf = DC::Import::CalaisFetcher.new.fetch_rdf(@text)
    File.open(path, 'w+') {|f| f.write(rdf) }
    path
  end
  
end