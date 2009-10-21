class LabelsController < ApplicationController
    
  before_filter :login_required
  
  def index
    json 'labels' => current_account.labels
  end
  
  def create
    json current_account.labels.create(pick_params(:title))
  end
  
  def update
    current_label.update_attributes(pick_params(:title, :document_ids))
    json label
  end  
  
  def destroy
    current_label.destroy
    json nil
  end
  
  
  private
  
  def current_label
    current_account.labels.find(params[:id])
  end
  
end