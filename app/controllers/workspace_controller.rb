class WorkspaceController < ApplicationController
  
  before_filter :authenticate unless Rails.development?
    
  def index;  end
  
  def signup; end
  
end