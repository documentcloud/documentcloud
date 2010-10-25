class CollaboratorsController < ApplicationController

  def index
    collabs = current_project.other_collaborators(current_account)
    json collabs.to_json(:include_organization => true)
  end

  def create
    account = Account.lookup(pick(:model, :email)[:email])
    return json(nil, 404) if !account || account.id == current_account.id
    current_project.add_collaborator account
    json account.to_json(:include_organization => true)
  end

  def destroy
    account = Account.find(params[:id])
    current_project.remove_collaborator account
    json nil
  end


  private

  def current_project
    Project.accessible(current_account).find(params[:project_id])
  end

end