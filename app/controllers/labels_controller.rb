class LabelsController < ApplicationController
    
  before_filter :login_required
  
  def index
    json 'labels' => current_account.labels
  end
  
  def create
    json current_account.labels.create(pick_params(:title))
  end
  
  # TODO: Implement update for changing the title of a label.
  
  def destroy
    current_account.labels.find(params[:id]).destroy
    json nil
  end
  
end