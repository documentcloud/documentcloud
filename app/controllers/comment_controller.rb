class CommentController < ActiveRecord::Base
  def create
    
  end
  
  # def destroy
  # end

  def index
  end  
  
  def show
    
  end
  
  def update
  end
  
  private
  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end
  
  def current_annotation
    @current_annotation ||= current_document.annotations.find_by_id(params[:id])
  end
  
end