class AnnotationsController < ApplicationController
  include DC::Access

  before_filter :login_required

  # In the workspace, request a listing of annotations, scoped not to the notes
  # that you can see, but the notes that you've written yourself.
  def index
    json current_document.annotations.accessible(current_account)
  end

  # Any account can create a private note on any document.
  # Only the owner of the document is allowed to create a public annotation.
  def create
    note_attrs = pick(:model, :page_number, :title, :content, :location, :access)
    doc = current_document
    return forbidden unless note_attrs[:access].to_i == PRIVATE || current_account.allowed_to_edit?(doc)
    expire_page doc.canonical_cache_path if doc.cacheable?
    json :model => doc.annotations.create(
      note_attrs.merge(:account_id => current_account.id, :organization_id => current_organization.id)
    )
  end

  # You can only alter annotations that you've made yourself.
  def update
    return not_found unless anno = current_annotation
    if !current_account.allowed_to_edit?(anno)
      anno.errors.add_to_base "You don't have permission to update the note."
      return json(anno, 403)
    end
    anno.update_attributes(pick(:model, :title, :content))
    expire_page current_document.canonical_cache_path if current_document.cacheable?
    json :model => anno
  end

  def destroy
    return not_found unless anno = current_annotation
    if !current_account.allowed_to_edit?(anno)
      anno.errors.add_to_base "You don't have permission to delete the note."
      return json(anno, 403)
    end
    anno.destroy
    expire_page current_document.canonical_cache_path if current_document.cacheable?
    json nil
  end


  private

  def current_annotation
    @current_annotation ||= current_document.annotations.find_by_id(params[:id])
  end

  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end