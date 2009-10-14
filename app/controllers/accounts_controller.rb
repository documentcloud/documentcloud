class AccountsController < ApplicationController
  layout nil
  
  before_filter :login_required
  
  def index
    json 'accounts' => current_organization.accounts
  end
  
  def create
    attributes = pick_params(:first_name, :last_name, :email)
    account = current_organization.accounts.create(attributes)
    account.create_security_key
    json account
  end
  
  # Journalists are authorized to update any account in the organization.
  # Think about what the desired level of access control is.
  def update
    account = current_organization.accounts.find(params[:id])
    account.update_attributes pick_params(:first_name, :last_name, :email)
    json account
  end
  
  def destroy
    current_organization.accounts.find(params[:id]).destroy
    json nil
  end
  
end