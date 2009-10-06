class WorkspaceController < ApplicationController
  
  before_filter :bouncer unless Rails.development?
    
  def index
    @account = current_account
  end
  
  def signup
    return render unless request.post?
    org = Organization.create(params[:organization])
    Account.create(params[:account].merge({:organization => org}))
  end
  
  def login
    return render unless request.post?
    account = Account.log_in(params[:email], params[:password], session)
    account ? redirect_to('/workspace') : @failed_login = true
  end
  
  def logout
    reset_session
    redirect_to '/'
  end
  
end