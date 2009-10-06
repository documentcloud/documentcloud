class WorkspaceController < ApplicationController
  
  before_filter :bouncer unless Rails.development?
    
  def index
    # temporary -- until we have real accounts.
    @account = !!params[:account]
  end
  
  def signup
    return render(:action => 'signup') unless request.post?
    org = Organization.create(params[:organization])
    Account.create(params[:account].merge({:organization => org}))
  end
  
  def login
    
  end
  
end