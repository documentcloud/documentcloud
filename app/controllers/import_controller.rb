class ImportController < ApplicationController

  FILE_URL = /\Afile:\/\//

  layout nil

  skip_before_action :verify_authenticity_token, :only => [:cloud_crowd, :update_access]

  before_action :secure_only,    :only => [:upload_document]
  before_action :login_required, :only => [:upload_document]
  before_action :read_only_error if read_only?

  # Internal document upload, called from the workspace.
  def upload_document
    return bad_request unless params[:file]
    @document = Document.upload(params, current_account, current_organization)
    @project_id = params[:project]
    if params[:multi_file_upload]
      json @document
    else
      # Render the HTML/script...
    end
  end

  # Returning a "201 Created" ack tells CloudCrowd to clean up the job.
  def cloud_crowd
    cloud_crowd_job = JSON.parse(params[:job])
    if processing_job = ProcessingJob.lookup_by_remote(cloud_crowd_job)
      processing_job.resolve(cloud_crowd_job) do |pj| 
        expire_document_cache pj.document
      end
    end
    
    #render :plain => '201 Created', :status => 201
    render :plain => "Created but don't clean up the job right now."
  end
  
  # CloudCrowd is done changing the document's asset access levels.
  # 201 created cleans up the job.
  def update_access
    cloud_crowd_job = JSON.parse(params[:job])
    if processing_job = ProcessingJob.lookup_by_remote(cloud_crowd_job)
      processing_job.resolve(cloud_crowd_job) do |pj| 
        expire_document_cache pj.document
      end
    end

    render :plain => '201 Created', :status => 201
  end

  def expire_document_cache(document)
    if document
      paths = document.cache_paths + document.annotations.map(&:cache_paths)
      expire_pages paths
    end
  end
end