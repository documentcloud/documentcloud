class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def create
    return forbidden unless current_document and current_annotation and current_document.allows_comments?
    comment = Comment.create(
      :document_id => current_document.id, 
      :annotation_id => current_annotation.id, 
      :commenter_id => ((current_account and current_account.commenter_id) || anonymous_commenter.id), 
      :text => params[:text]
    )
    @response = Comment.populate_author_info([comment], current_account).first
    json_response
  end
  
  # def destroy
  # end

  def index
    @response = Comment.find_all_by_annotation_id(current_annotation.id)
    json_response
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
  
  def anonymous_commenter
    @current_commenter = Commenter.find_by_email("anonymous@documentcloud.org")
  end
end
