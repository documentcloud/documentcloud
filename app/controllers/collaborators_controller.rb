class CollaboratorsController < ApplicationController

  def index
    json current_project.collaborators
  end

  def create
    account = Account.lookup(pick(:json, :email)[:email])
    return json(nil, 404) if !account || account.id == current_account.id
    current_project.add_collaborator account
    json account
  end

  def destroy
    account = Account.find(params[:id])
    current_project.remove_collaborator account
    json nil
  end


  private

  def current_project
    current_account.projects.find(params[:project_id])
  end

end