class ImportController < ApplicationController
  
  FILE_URL = /\Afile:\/\//
  
  def cloud_crowd
    job = JSON.parse(params[:job])
    raise "CloudCrowd processing failed" if job['status'] != 'succeeded'
    job['outputs'].each do |result|
      logger.info "Importing #{File.basename(result['pdf_url'])}"
      doc = Document.new({
        :title =>                 result['title'],
        :pdf_path =>              result['pdf_url'],
        # :full_text =>             File.read(result['full_text_url'].sub(FILE_URL, '')),
        # :rdf =>                   File.read(result['rdf_url'].sub(FILE_URL, '')),
        :full_text =>             RestClient.get(result['full_text_url']),
        :rdf =>                   RestClient.get(result['rdf_url']),
        :thumbnail_path =>        result['thumbnail_url'],
        :small_thumbnail_path =>  result['small_thumbnail_url'],
        :organization =>          Faker::Company.name
      })
      DC::Import::MetadataExtractor.new.extract_metadata(doc)
      doc.save
    end
    
    # Cleaning up later so that we don't deadlock in development.
    Thread.new do
      sleep 1
      RestClient.delete DC_CONFIG['cloud_crowd_server'] + "/jobs/#{job['id']}"
    end
    
    render :nothing => true
  end
  
end