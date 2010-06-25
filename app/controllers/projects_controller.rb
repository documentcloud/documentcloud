class ProjectsController < ApplicationController

  before_filter :login_required

  def index
    json 'projects' => Project.accessible(current_account)
  end

  def create
    json current_account.projects.create(pick(:json, :title, :document_ids))
  end

  # TODO: Ensure that the document ids you're adding are for documents you
  # have access to.
  def update
    current_project(true).update_attributes(pick(:json, :title, :document_ids))
    json current_project
  end

  def destroy
    current_project.destroy
    json nil
  end

  def documents
    json 'documents' => current_project.loaded_documents
  end


  private

  def current_project(accessible=false)
    base = (accessible ? Project.accessible(current_account) : current_account.projects)
    base.find(params[:id])
  end

end