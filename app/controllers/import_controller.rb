class ImportController < ApplicationController
  
  def dogpile
    job = JSON.parse(params[:job])
    job['inputs'].each do |pdf_url, status|
      if status == 'succeeded'
        logger.info "Importing #{File.basename(pdf_url)}"
        result = JSON.parse(job['outputs'][pdf_url])
        doc = Document.new({
          :title =>                 result['title'],
          :pdf_path =>              pdf_url,
          :full_text =>             RestClient.get(result['full_text_url']),
          :rdf =>                   RestClient.get(result['rdf_url']),
          :thumbnail_path =>        result['thumbnail_url'],
          :small_thumbnail_path =>  result['small_thumbnail_url']
        })
        DC::Import::MetadataExtractor.new.extract_metadata(doc)
        doc.save
      end
    end
    
    # Cleaning up later so that we don't deadlock in development.
    Thread.new do
      sleep 1
      RestClient.delete DC::CONFIG['dogpile_server'] + "/jobs/#{job['id']}"
    end
    
    render :nothing => true
  end
  
end