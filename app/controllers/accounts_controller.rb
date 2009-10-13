class AccountsController < ApplicationController
  layout nil
  
  before_filter :login_required
  
  def index
    json 'accounts' => current_organization.accounts
  end
  
end