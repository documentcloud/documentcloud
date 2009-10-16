class AccountsController < ApplicationController
  layout 'workspace'
  
  before_filter :login_required, :except => [:enable]
  before_filter :bouncer, :only => [:enable] unless Rails.development?
  
  def enable
    return render if request.get?
    key = SecurityKey.find_by_key(params[:key])
    @failure = true and return render unless key
    account = key.securable
    account.password = params[:password]
    account.save
    account.authenticate(session)
    key.destroy
    redirect_to '/workspace'
  end
  
  def index
    json 'accounts' => current_organization.accounts
  end
  
  def create
    attributes = pick_params(:first_name, :last_name, :email)
    account = current_organization.accounts.create(attributes)
    account.send_login_instructions
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