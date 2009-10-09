class ImportController < ApplicationController
  
  FILE_URL = /\Afile:\/\//
  
  before_filter :login_required, :only => [:upload_pdf]
  
  def upload_pdf
    pdf = params[:pdf]
    save_path = "docs/#{pdf.original_filename.gsub(/[^a-zA-Z0-9_\-.]/, '-').gsub(/-+/, '-')}"
    FileUtils.cp(pdf.path, "#{RAILS_ROOT}/public/#{save_path}")
    urls = ["#{DC_CONFIG['server_root']}/#{save_path}"]
    options = {
      'title' => params[:title], 
      'source' => params[:source],
      'organization_id' => current_organization.id,
      'account_id' => current_account.id,
      'access' => DC::Access::PUBLIC
    }
    DC::Import::CloudCrowdImporter.new.import(urls, options)
    redirect_to DC_CONFIG['cloud_crowd_server']
  end
  
  def cloud_crowd
    job = JSON.parse(params[:job])
    raise "CloudCrowd processing failed" if job['status'] != 'succeeded'
    
    # Finishing the job later so that we don't deadlock in development.
    Thread.new do
      job['outputs'].each do |result|
        name = File.basename(result['pdf_url'])
        logger.info "Import: #{name} starting..."
        doc = Document.new({
          :title                => result['title'],
          :organization_id      => result['organization_id'],
          :account_id           => result['account_id'],
          :access               => result['access'],
          :source               => result['source'] || Faker::Company.name,          
          :pdf_path             => result['pdf_url'],
          :full_text            => fetch_contents(result['full_text_url']),
          :rdf                  => fetch_contents(result['rdf_url']),
          :thumbnail_path       => result['thumbnail_url'],
          :small_thumbnail_path => result['small_thumbnail_url']
        })
        DC::Import::MetadataExtractor.new.extract_metadata(doc)
        doc.save
        logger.info "Import: #{name} saved"
      end
      DC::Store::FullTextStore.new.index
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