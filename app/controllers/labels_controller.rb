class LabelsController < ApplicationController

  before_filter :login_required

  def index
    json 'labels' => current_account.labels.alphabetical
  end

  def create
    json current_account.labels.create(pick_params(:title, :document_ids))
  end

  def update
    current_label.update_attributes(pick_params(:title, :document_ids))
    json current_label
  end

  def destroy
    current_label.destroy
    json nil
  end

  def documents
    json 'documents' => current_label.loaded_documents
  end


  private

  def current_label
    current_account.labels.find(params[:id])
  end

end