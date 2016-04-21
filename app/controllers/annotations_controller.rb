class AnnotationsController < ApplicationController
  include DC::Access

  layout false

  before_action :login_required, :except => [:index, :show, :print, :cors_options]
  before_action :prefer_secure, :only => [:show]
  skip_before_action :verify_authenticity_token
  after_action  :allow_iframe, :only => [:show]

  READONLY_ACTIONS = [
    :index, :show, :print, :cors_options
  ]
  before_action :read_only_error, :except => READONLY_ACTIONS if read_only?

  # In the workspace, request a listing of annotations.
  def index
    annotations = current_document.annotations_with_authors(current_account)
    json annotations
  end

  def show
    return not_found unless current_annotation

    respond_to do |format|
      format.json do
        @response = current_annotation.canonical(:include_image_url => true, :include_document_url => true)
        # TODO: https://github.com/documentcloud/documentcloud/issues/291
        # cache_page @response.to_json if current_annotation.cacheable?
        render_cross_origin_json
      end
      format.js do
        json = current_annotation.canonical(:include_image_url => true, :include_document_url => true).to_json
        js = "dc.embed.noteCallback(#{json})"
        cache_page js if current_annotation.cacheable?
        render :js => js
      end
      format.html do
        @current_annotation_dimensions = current_annotation.embed_dimensions
        if params[:embed] == 'true'
          # We have a special, extremely stripped-down show page for when we're
          # being iframed. The normal show page can also be iframed, but there
          # will be a flash of unwanted layout elements before the JS/CSS 
          # arrives which removes them.
          @embedded = true
          @exclude_analytics = true
          render template: 'annotations/show_embedded', layout: 'minimal'
        else
          make_oembeddable(current_annotation)
          render layout: 'minimal'
        end
      end
    end
  end

  # Print out all the annotations for a document (or documents.)
  def print
    return bad_request unless params[:docs].is_a?(Array)
    docs = Document.accessible(current_account, current_organization).where( :id => params[:docs] )
    Document.populate_annotation_counts(current_account, docs)
    @documents_json = docs.map {|doc| doc.to_json(:annotations => true, :account => current_account) }
    render :layout => nil
  end

  # Any account can create a private note on any document.
  # Only the owner of the document is allowed to create a public annotation.
  def create
    maybe_set_cors_headers
    note_attrs = pick(params, :page_number, :title, :content, :location, :access)
    note_attrs[:access] = ACCESS_MAP[note_attrs[:access].to_sym]
    doc = current_document
    return forbidden unless note_attrs[:access] == PRIVATE || current_account.allowed_to_comment?(doc)
    expire_pages doc.cache_paths if doc.cacheable?
    note_attrs[:organization_id] = current_account.organization_id
    anno = doc.annotations.create(note_attrs.merge(
      :account_id      => current_account.id
    ))
    json current_document.annotations_with_authors(current_account, [anno]).first
  end

  # You can only alter annotations that you've made yourself.
  def update
    maybe_set_cors_headers
    return not_found unless anno = current_annotation
    return forbidden(:error => "You don't have permission to update the note.") unless current_account.allowed_to_edit?(anno)
    attrs = pick(params, :title, :content, :access)
    attrs[:access] = DC::Access::ACCESS_MAP[attrs[:access].to_sym]
    anno.update_attributes(attrs)
    expire_pages current_document.cache_paths if current_document.cacheable?
    expire_pages current_annotation.cache_paths if current_annotation.cacheable?
    anno.reset_public_note_count
    json anno
  end

  def destroy
    maybe_set_cors_headers
    return not_found unless anno = current_annotation
    return forbidden(:error => "You don't have permission to delete the note.") unless current_account.allowed_to_edit?(anno)
    anno.destroy
    expire_pages current_document.cache_paths if current_document.cacheable?
    json nil
  end

  def cors_options
    return bad_request unless params[:allowed_methods]
    maybe_set_cors_headers
    render :nothing => true
  end

  private

  def current_annotation
    @current_annotation ||= current_document.annotations.find_by_id(params[:id])
  end

  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end
