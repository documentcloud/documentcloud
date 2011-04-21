class AnnotationsController < ApplicationController
  include DC::Access

  before_filter :login_required, :except => [:index]

  # In the workspace, request a listing of annotations.
  def index
    annotations = current_document.annotations_with_authors(current_account)
    json annotations
  end
  
  def show
    respond_to do |format|
      format.js do
        json = current_annotation.canonical(:include_image_url => true, :include_document_url => true).to_json
        js = "dc.embed.noteCallback(#{json})"
        cache_page js if current_annotation.cacheable?
        render :js => js
      end
    end
  end

  # Any account can create a private note on any document.
  # Only the owner of the document is allowed to create a public annotation.
  def create
    note_attrs = pick(params, :page_number, :title, :content, :location, :access)
    note_attrs[:access] = ACCESS_MAP[note_attrs[:access].to_sym]
    doc = current_document
    return forbidden unless note_attrs[:access] == PRIVATE || current_account.allowed_to_edit?(doc) || current_account.reviews?(doc)
    expire_page doc.canonical_cache_path if doc.cacheable?
    anno = doc.annotations.create(note_attrs.merge(
      :account_id      => current_account.id,
      :organization_id => current_organization.id
    ))
    expire_page current_annotation.canonical_cache_path if current_annotation.cacheable?
    json current_document.annotations_with_authors(current_account, [anno]).first
  end

  # You can only alter annotations that you've made yourself.
  def update
    return not_found unless anno = current_annotation
    if !current_account.allowed_to_edit?(anno)
      anno.errors.add_to_base "You don't have permission to update the note."
      return json(anno, 403)
    end
    attrs = pick(params, :title, :content, :access)
    attrs[:access] = DC::Access::ACCESS_MAP[attrs[:access].to_sym]
    anno.update_attributes(attrs)
    expire_page current_document.canonical_cache_path if current_document.cacheable?
    expire_page current_annotation.canonical_cache_path if current_annotation.cacheable?
    anno.reset_public_note_count
    json anno
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