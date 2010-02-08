class ProjectsController < ApplicationController

  before_filter :login_required

  def index
    json 'projects' => current_account.projects.alphabetical
  end

  def create
    json current_account.projects.create(pick(:json, :title, :document_ids))
  end

  def update
    current_project.update_attributes(pick(:json, :title, :document_ids))
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

  def current_project
    current_account.projects.find(params[:id])
  end

end