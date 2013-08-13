class CollaboratorsController < ApplicationController

  def create
    account = Account.lookup(pick(params, :email)[:email])
    return json(nil, 404) if !account || account.id == current_account.id
    return json({:errors => ['That account has been disabled.']}, 409) if account.role == Account::DISABLED
    success = current_project.add_collaborator account
    return json(account, 409) unless success
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
