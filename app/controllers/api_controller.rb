# The public DocumentCloud API.
class ApiController < ApplicationController
  include DC::Access
  include DC::Search::Controller

  layout 'workspace'

  before_filter :bouncer if Rails.env.staging?

  before_filter :api_login_required, :only => [:upload, :projects, :update]
  before_filter :api_login_optional, :only => [:documents, :search]
  before_filter :login_required, :only => [:index]

  API_OPTIONS = {:sections => false, :annotations => false, :access => true, :contributor => false}

  def index
  end

  def signup
    return render unless request.post?
  end

  def search
    perform_search
    respond_to do |format|
      format.any(:js, :json) do
        @response = ActiveSupport::OrderedHash.new
        @response['total']      = @query.total
        @response['page']       = @query.page
        @response['per_page']   = DC::Search::DEFAULT_PAGE_SIZE
        @response['documents']  = @documents.map {|d| d.canonical(API_OPTIONS) }
        return if jsonp_request?
        render :json => @response
      end
    end
  end

  # Upload API, similar to our internal upload API for starters. Parameters:
  # file, title, access, source, description.
  def upload
    return bad_request unless params[:file] && params[:title] && current_account
    if !params[:file].respond_to? :path
      return render({:json => {:message => "The file parameter must be the contents of a file."},
                    :status => 400})
    end
    @response = Document.upload(params, current_account, current_organization).canonical
    return if jsonp_request?
    render :json => @response
  end

  # Retrieve a document's canonical JSON.
  def documents
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless current_document
    @response = {'document' => current_document.canonical(:access => true, :sections => true, :annotations => true)}
    return if jsonp_request?
    render :json => @response
  end

  # Retrieve the entities for a document.
  def entities
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless current_document
    @response = {'entities' => current_document.ordered_entity_hash}
    return if jsonp_request?
    render :json => @response
  end

  def update
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless doc = current_document
    attrs = pick(params, :access, :title, :description, :source, :related_article, :remote_url)
    attrs[:access] = ACCESS_MAP[attrs[:access].to_sym] if attrs[:access]
    success = doc.secure_update attrs, current_account
    return json(doc, 403) unless success
    expire_page doc.canonical_cache_path if doc.cacheable?
    @response = {'document' => doc.canonical(:access => true, :sections => true, :annotations => true)}
    return if jsonp_request?
    render :json => @response
  end

  # Retrieve a listing of your projects, including document id.
  def projects
    return bad_request unless current_account && (request.format.json? || request.format.js?)
    @response = {'projects' => Project.accessible(current_account).map {|p| p.canonical } }
    return if jsonp_request?
    render :json => @response
  end


  private

  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find_by_id(params[:id].to_i)
  end

end