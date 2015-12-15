class CollaboratorsController < ApplicationController

  before_action :login_required

  def create
    account = Account.lookup(pick(params, :email)[:email])
    return not_found if !account
    return conflict if account.id == current_account.id
    return bad_request(:error => 'That account has been disabled.') if account.role == Account::DISABLED
    
    success = current_project.add_collaborator account
    # TODO: Are we actually expecting the contents of `account`? [JR]
    # - If we're using `account.errors`, can be reduced to `json(account)`
    # - If we're not using it, can be reduced to `conflict`
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
