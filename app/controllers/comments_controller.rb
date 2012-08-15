class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def create
    return forbidden unless current_annotation and current_annotation.allows_comments? current_account
    comment = Comment.new(
      :document_id   => current_document.id, 
      :annotation_id => current_annotation.id,
      :account_id    => ((current_account and current_account.id) or anonymous_commenter.id),
      :text          => params[:text],
      :access        => params[:access]
    )
    if comment.save
      @response = comment
      expire_page current_document.canonical_cache_path if current_document.cacheable?
      expire_page current_annotation.canonical_cache_path if current_annotation.cacheable?
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
    return not_found unless comment = current_comment
    unless current_account.allowed_to_edit?(comment) or current_account.allowed_to_edit(current_document)
      comment.errors.add_to_base "You don't have permission to update this comment."
      return json(comment, 403)
    end

    attrs = pick(params, :text, :access)
    attrs[:access] = DC::Access::ACCESS_MAP[attrs[:access].to_sym]
    comment.update_attributes(attrs)
    expire_page current_document.canonical_cache_path if current_document.cacheable?
    expire_page current_annotation.canonical_cache_path if current_annotation.cacheable?
    json comment
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
    return nil unless current_annotation
    @current_comment ||= current_annotation.comments.find_by_id(params[:id])
  end
  
  def anonymous_commenter
    @current_commenter = Account.find_by_email("anonymous@documentcloud.org")
  end
end
