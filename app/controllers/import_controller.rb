class ImportController < ApplicationController

  FILE_URL = /\Afile:\/\//

  layout nil

  before_filter :login_required, :only => [:upload_document]

  def upload_document
    @bad_request = true and return unless params[:file] && params[:title]
    @project_id  = params[:project_id]
    @document    = Document.upload(params, current_account, current_organization)
    Project.accessible(current_account).find(@project_id).add_document(@document) if @project_id
  end

  # Returning a "201 Created" ack tells CloudCrowd to clean up the job.
  # If the document failed to import, we remove it.
  def cloud_crowd
    job = JSON.parse(params[:job])
    if job['status'] != 'succeeded'
      logger.error("Document import failed: " + job.inspect)
      record = ProcessingJob.find_by_cloud_crowd_id(job['id'])
      record.document.update_attributes(:access => DC::Access::ERROR) if record && record.document
    end
    ProcessingJob.destroy_all(:cloud_crowd_id => job['id'])
    render :text => '201 Created', :status => 201
  end

  # CloudCrowd is done changing the document's asset access levels.
  # 201 created cleans up the job.
  def update_access
    render :text => '201 Created', :status => 201
  end

end