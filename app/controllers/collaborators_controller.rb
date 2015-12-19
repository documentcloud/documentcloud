class CollaboratorsController < ApplicationController

  before_action :login_required
  before_action :read_only_error if read_only?

  def create
    account = Account.lookup(pick(params, :email)[:email])
    return not_found if !account
    return conflict if account.id == current_account.id
    return bad_request(:error => 'That account has been disabled.') if account.role == Account::DISABLED
    # TODO: If we're not using `account.errors`, can be reduced to 
    # `bad_request` [JR]
    return json(account, 400) unless current_project.add_collaborator account
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
