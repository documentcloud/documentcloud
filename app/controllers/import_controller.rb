class ImportController < ApplicationController
  
  FILE_URL = /\Afile:\/\//
  
  def upload_pdf
    pdf = params[:pdf]
    save_path = "docs/#{pdf.original_filename}"
    FileUtils.cp(pdf.path, "#{RAILS_ROOT}/public/#{save_path}")
    urls = ["#{DC_CONFIG['server_root']}/#{save_path}"]
    options = {'title' => params[:title], 'source' => params[:source]}
    DC::Import::CloudCrowdImporter.new.import(urls, options)
    redirect_to DC_CONFIG['cloud_crowd_server']
  end
  
  def cloud_crowd
    job = JSON.parse(params[:job])
    raise "CloudCrowd processing failed" if job['status'] != 'succeeded'
    job['outputs'].each do |result|
      logger.info "Importing #{File.basename(result['pdf_url'])}"
      doc = Document.new({
        :title                => result['title'],
        :organization         => result['source'],
        :pdf_path             => result['pdf_url'],
        :full_text            => fetch_contents(result['full_text_url']),
        :rdf                  => fetch_contents(result['rdf_url']),
        :thumbnail_path       => result['thumbnail_url'],
        :small_thumbnail_path => result['small_thumbnail_url']
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
  
  
  private
  
  # Read the contents of a URL, whether local or remote.
  def fetch_contents(url)
    url.match(FILE_URL) ? File.read(url.sub(FILE_URL, '')) : RestClient.get(url)
  end
  
end