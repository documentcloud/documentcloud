class AnnotationsController < ApplicationController
  include DC::Access

  before_filter :login_required

  # In the workspace, request a listing of annotations, scoped not to the notes
  # that you can see, but the notes that you've written yourself.
  def index
    json current_document.annotations.owned_by(current_account).in_order
  end

  # Any account can create a private note on any document.
  # Only the owner of the document is allowed to create a public annotation.
  def create
    note_attrs = pick(:json, :page_number, :title, :content, :location, :access)
    return forbidden unless note_attrs[:access].to_i == PRIVATE || current_account.owns_or_administers?(current_document)
    json current_document.annotations.create(
      note_attrs.merge(:account_id => current_account.id, :organization_id => current_organization.id)
    )
  end

  # You can only alter annotations that you've made yourself.
  def update
    return forbidden unless current_account.owns_or_administers?(current_annotation)
    current_annotation.update_attributes(pick(:json, :title, :content))
    json current_annotation
  end

  def destroy
    return forbidden unless current_account.owns_or_administers?(current_annotation)
    current_annotation.destroy
    json nil
  end


  private

  def current_annotation
    @current_annotation ||= current_document.annotations.find(params[:id])
  end

  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end