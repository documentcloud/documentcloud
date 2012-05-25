class CommentsController < ApplicationController
  def create
    return forbidden unless current_document and current_annotation and current_account
    comment = Comment.create(:document_id => current_annotation.document_id, :annotation_id => current_annotation.id, :commenter_id => current_account.id, :text=>params[:text])
    json Comment.populate_author_info([comment], current_account).first
  end
  
  # def destroy
  # end

  def index
    
  end  
  
  def show
    return not_found unless current_annotation and current_comment
    respond_to do |format|
      format.any(:json,:js) do
        @response = current_comment.canonical.to_json
        json_response
      end
    end
  end
  
  def update
  end
  
  private
  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end
  
  def current_annotation
    @current_annotation ||= current_document.annotations.find_by_id(params[:annotation_id])
  end
  
  def current_comment
    @current_comment ||= Comment.first(:conditions=>{:id=>params[:id], :annotation_id => current_annotation.id})
  end
end
