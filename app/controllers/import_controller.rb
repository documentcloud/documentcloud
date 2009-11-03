class ImportController < ApplicationController
  
  FILE_URL = /\Afile:\/\//
  
  before_filter :login_required, :only => [:upload_pdf]
  
  def upload_pdf
    pdf = params[:pdf]
    save_dir = "#{RAILS_ROOT}/public/docs"
    Dir.mkdir(save_dir) unless File.exists?(save_dir)
    save_path = pdf.original_filename.gsub(/[^a-zA-Z0-9_\-.]/, '-').gsub(/-+/, '-')
    FileUtils.cp(pdf.path, File.join(save_dir, save_path))
    urls = ["#{DC_CONFIG['server_root']}/docs/#{save_path}"]
    options = {
      'title' => params[:title], 
      'source' => params[:source],
      'organization_id' => current_organization.id,
      'account_id' => current_account.id,
      'access' => params[:access].to_i
    }
    DC::Import::CloudCrowdImporter.new.import(urls, options)
    redirect_to DC_CONFIG['cloud_crowd_server']
  end
  
  # Returning a "201 Created" ack tells CloudCrowd to clean up the job.
  def cloud_crowd
    render :text => '201 Created', :status => 201
  end
  
  
  private
  
  # Read the contents of a URL, whether local or remote.
  def fetch_contents(url)
    url.match(FILE_URL) ? File.read(url.sub(FILE_URL, '')) : RestClient.get(url)
  end
  
end