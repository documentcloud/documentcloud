class ImportController < ApplicationController

  FILE_URL = /\Afile:\/\//

  layout nil

  before_filter :login_required, :only => [:upload_document]

  # TODO: Clean up this method.
  def upload_document
    return bad_request unless params[:file]
    basename    = File.basename(params[:file].original_filename.gsub(/[^a-zA-Z0-9_\-.]/, '-').gsub(/-+/, '-'))
    doc = Document.create!(
      :title            => params[:title] || basename,
      :source           => params[:source],
      :organization_id  => current_organization.id,
      :account_id       => current_account.id,
      :access           => DC::Access::PENDING,
      :page_count       => 0
    )
    DC::Store::AssetStore.new.save_pdf(doc, params[:file].path)
    job = JSON.parse(DC::Import::CloudCrowdImporter.new.import([doc.id], {
      'id'            => doc.id,
      'basename'      => basename,
      'access'        => params[:access].to_i
    }))
    record = ProcessingJob.create!(
      :account        => current_account,
      :cloud_crowd_id => job['id'],
      :title          => doc.title,
      :remote_job     => job
    )
    @status = record.status
  end

  # Returning a "201 Created" ack tells CloudCrowd to clean up the job.
  # If the document failed to import, we remove it.
  def cloud_crowd
    job = JSON.parse(params[:job])
    if job['status'] != 'succeeded'
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