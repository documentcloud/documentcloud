class ImportController < ApplicationController

  FILE_URL = /\Afile:\/\//

  layout nil

  before_filter :login_required, :only => [:upload_document]

  def upload_document
    return bad_request unless params[:file]
    path = ensure_pdf
    doc  = new_document
    DC::Store::AssetStore.new.save_pdf(doc, path)
    cloud_crowd_import(doc)
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

  # A new, pending document for the request.
  def new_document
    Document.create!(
      :title            => params[:title],
      :source           => params[:source],
      :organization_id  => current_organization.id,
      :account_id       => current_account.id,
      :access           => DC::Access::PENDING,
      :page_count       => 0
    )
  end

  # Make sure we're dealing with a PDF. If not, it needs to be
  # converted first. Return the path to the converted document.
  def ensure_pdf
    path = params[:file].path
    ext  = File.extname(params[:file].original_filename)
    return path if ext == '.pdf'
    Docsplit.extract_pdf(path)
    File.basename(path, ext) + '.pdf'
  end

  # Kick off and record a CloudCrowd document import job.
  def cloud_crowd_import(document)
    job = JSON.parse(DC::Import::CloudCrowdImporter.new.import([document.id], {
      'id'            => document.id,
      'access'        => params[:access].to_i
    }))
    record = ProcessingJob.create!(
      :account        => current_account,
      :cloud_crowd_id => job['id'],
      :title          => document.title,
      :remote_job     => job
    )
    @status = record.status
  end

end