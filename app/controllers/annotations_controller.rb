class AnnotationsController < ApplicationController

  before_filter :login_required

  def create
    json current_document.annotations.create(pick_params(:page_number, :title, :content, :location))
  end

  def destroy
    current_annotation.destroy
    json nil
  end


  private

  def current_annotation
    current_document.annotations.find(params[:id])
  end

  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end