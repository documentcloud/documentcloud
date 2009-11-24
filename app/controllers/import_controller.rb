class ImportController < ApplicationController

  FILE_URL = /\Afile:\/\//

  layout nil

  before_filter :login_required, :only => [:upload_pdf]

  # TODO: Clean up this method.
  def upload_pdf
    pdf = params[:pdf]
    save_dir = "#{RAILS_ROOT}/public/docs"
    Dir.mkdir(save_dir) unless File.exists?(save_dir)
    save_path = pdf.original_filename.gsub(/[^a-zA-Z0-9_\-.]/, '-').gsub(/-+/, '-')
    local_path = File.join(save_dir, save_path)
    FileUtils.cp(pdf.path, local_path)
    urls = ["#{DC_CONFIG['server_root']}/docs/#{save_path}"]
    options = {
      'title'           => params[:title],
      'source'          => params[:source],
      'organization_id' => current_organization.id,
      'account_id'      => current_account.id,
      'access'          => params[:access].to_i,
      'original_pdf'    => local_path
    }
    response = DC::Import::CloudCrowdImporter.new.import(urls, options)
    job = JSON.parse(response)
    record = ProcessingJob.create!(
      :account        => current_account,
      :cloud_crowd_id => job['id'],
      :title          => options['title'],
      :remote_job     => job
    )
    @status = record.status
  end

  # Returning a "201 Created" ack tells CloudCrowd to clean up the job.
  # If the document failed to import, we remove it.
  def cloud_crowd
    job = JSON.parse(params[:job])
    if job['status'] == 'succeeded'
      doc = job['outputs'].first['original_pdf']
      FileUtils.rm(doc) if File.exists?(doc) && doc.match(/\.pdf\Z/)
    else
      logger.warn("Document import failed: " + job.inspect)
    end
    ProcessingJob.destroy_all(:cloud_crowd_id => job['id'])
    render :text => '201 Created', :status => 201
  end

  # Get the current status of an active processing job.
  def job_status
    job = current_account.processing_jobs.find_by_id(params[:id])
    json job && job.status
  end


  private

  # Read the contents of a URL, whether local or remote.
  def fetch_contents(url)
    url.match(FILE_URL) ? File.read(url.sub(FILE_URL, '')) : RestClient.get(url)
  end

end