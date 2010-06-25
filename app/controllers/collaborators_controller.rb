class CollaboratorsController < ApplicationController

  def index
    json current_project.other_collaborators(current_account).to_json(:include_organization => true)
  end

  def create
    account = Account.lookup(pick(:json, :email)[:email])
    return json(nil, 404) if !account || account.id == current_account.id
    current_project.add_collaborator account
    json account.to_json(:include_organization => true)
  end

  def destroy
    account = Account.find(params[:id])
    current_project.remove_collaborator account if current_project.account_id != account.id
    json nil
  end


  private

  def current_project
    Project.accessible(current_account).find(params[:project_id])
  end

end