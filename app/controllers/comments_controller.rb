class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def create
    return forbidden unless current_annotation and current_annotation.allows_comments? current_account
    comment = Comment.new(
      :document_id => current_document.id, 
      :annotation_id => current_annotation.id,
      :account_id => ((current_account and current_account.id) || anonymous_commenter.id),
      :text => params[:text],
      :access => params[:access]
    )
    if comment.save
      @response = comment
    else
      return json({:errors => comment.errors}, 409)
    end
    json_response
  end
  
  # def destroy
  # end

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
    return nil unless current_document
    @current_annotation ||= current_document.annotations.find_by_id(params[:annotation_id])
  end
  
  def current_comment
    @current_comment ||= Comment.first(:conditions=>{:id=>params[:id], :annotation_id => current_annotation.id})
  end
  
  def anonymous_commenter
    @current_commenter = Account.find_by_email("anonymous@documentcloud.org")
  end
end
