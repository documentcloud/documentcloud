# The public DocumentCloud API.
class ApiController < ApplicationController
  include DC::Search::Controller

  layout 'workspace'

  before_filter :bouncer if Rails.env.staging?

  before_filter :api_login_required, :only => [:upload, :projects]
  before_filter :api_login_optional, :only => [:documents, :search]
  before_filter :login_required, :only => [:index]

  API_OPTIONS = {:sections => false, :annotations => false}

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
    doc = Document.accessible(current_account, current_organization).find(params[:id].to_i)
    @response = {'document' => doc.canonical(:sections => true, :annotations => true) }
    render :json => @response
  end

  # Retrieve a listing of your projects, including document id.
  def projects
    return bad_request unless current_account && (request.format.json? || request.format.js?)
    @response = {'projects' => Project.accessible(current_account).map {|p| p.canonical } }
    return if jsonp_request?
    render :json => @response
  end

end