class ProjectsController < ApplicationController

  before_filter :login_required

  def index
    json 'projects' => Project.accessible(current_account)
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

  def add_collaborator
    account = Account.lookup(params[:email])
    if !account || account == current_account
      return render :text => 'No account could be found with that email address.', :status => 404
    end
    current_project.add_collaborator account
    json current_project
  end

  def remove_collaborator

  end


  private

  def current_project
    current_account.projects.find(params[:id])
  end

end