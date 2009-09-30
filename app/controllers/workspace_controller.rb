class WorkspaceController < ApplicationController
  
  before_filter :authenticate unless Rails.development?
    
  def index;
    # temporary -- until we have real accounts.
    @account = !!params[:account]
  end
  
  def signup; end
  
end