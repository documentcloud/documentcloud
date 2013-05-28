# The public DocumentCloud API.
class ApiController < ApplicationController
  include DC::Access
  include DC::Search::Controller

  layout 'workspace'

  before_filter :bouncer if Rails.env.staging?
  before_filter :prefer_secure, :only => [:index]

  skip_before_filter :verify_authenticity_token

  before_filter :secure_only,        :only => [:upload, :project, :projects, :upload, :destroy, :create_project, :update_project, :destroy_project]
  before_filter :api_login_required, :only => [:upload, :project, :projects, :update, :destroy, :create_project, :update_project, :destroy_project]
  before_filter :api_login_optional, :only => [:documents, :search, :notes, :pending, :entities]

  def index
    redirect_to '/help/api'
  end

  def cors_options
    return bad_request unless params[:allowed_methods]
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'OPTIONS, ' + params[:allowed_methods].map(&:to_s).map(&:upcase).join(', ')
    headers['Access-Control-Allow-Headers'] = 'Authorization'
    headers['Access-Control-Allow-Credentials'] = 'true'
    render :nothing => true
  end

  def search
    opts = API_OPTIONS.merge(pick(params, :sections, :annotations, :entities, :mentions, :data))
    if opts[:mentions] &&= opts[:mentions].to_i
      opts[:mentions] = 10  if opts[:mentions] > 10
      opts[:mentions] = nil if opts[:mentions] < 1
    end
    respond_to do |format|
      format.any(:js, :json) do
        perform_search :mentions => opts[:mentions]
        @response = ActiveSupport::OrderedHash.new
        @response['total']     = @query.total
        @response['page']      = @query.page
        @response['per_page']  = @query.per_page
        @response['q']         = params[:q]
        @response['documents'] = @documents.map {|d| d.canonical(opts) }
        json_response
      end
    end
  end

  # Upload API, similar to our internal upload API for starters. Parameters:
  # file, title, access, source, description.
  # The `file` must either be a multipart file upload, or a URL to a remote doc.
  def upload
    secure_silence_logs do
      return bad_request unless params[:file] && params[:title] && current_account
      is_file = params[:file].respond_to?(:path)
      if !is_file && !(URI.parse(params[:file]) rescue nil)
        return render({
          :json => {:message => "The 'file' parameter must be the contents of a file or a URL."},
          :status => 400
        })
      end
      params[:url] = params[:file] unless is_file
      @response = Document.upload(params, current_account, current_organization).canonical
      json_response
    end
  end

  # Retrieve a document's canonical JSON.
  def documents
    return bad_request unless params[:id] and request.format.json? || request.format.js? || request.format.text?
    return not_found unless current_document
    opts                     = {:access => true, :sections => true, :annotations => true, :data => true}
    if current_account
      opts[:account]           = current_account
      opts[:allowed_to_edit]   = current_account.allowed_to_edit?(current_document)
      opts[:allowed_to_review] = current_account.reviews?(current_document)
    end
    @response                = {'document' => current_document.canonical(opts)}
    respond_to do |format|
      format.text do 
        direct = [PRIVATE, ORGANIZATION, EXCLUSIVE].include? current_document.access
        redirect_to(current_document.full_text_url(direct))
      end
      format.json { json_response }
      format.js { json_response }
    end
  end
  
  def pending
    @response = { :total_documents => Document.pending.count }
    @response[:your_documents] = Document.pending.count(:conditions => { :account_id => current_account.id }) if current_account
    json_response
  end
  
  # Retrieve a note's canonical JSON.
  def notes
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless current_note
    @response = {'annotation' => current_note.canonical}
    json_response
  end

  # Retrieve the entities for a document.
  def entities
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless current_document
    @response = {'entities' => current_document.ordered_entity_hash}
    json_response
  end

  def update
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless doc = current_document
    attrs = pick(params, :access, :title, :description, :source, :related_article, :published_url, :data)
    attrs[:access] = ACCESS_MAP[attrs[:access].to_sym] if attrs[:access]
    success = doc.secure_update attrs, current_account
    return json(doc, 403) unless success
    expire_page doc.canonical_cache_path if doc.cacheable?
    @response = {'document' => doc.canonical(:access => true, :sections => true, :annotations => true)}
    json_response
  end

  def destroy
    return bad_request unless request.delete?
    return not_found   unless doc = current_document
    return forbidden   unless current_account && current_account.owns_or_collaborates?(doc)
    doc.destroy
    json nil
  end

  # Retrieve information about one project
  def project
    return forbidden unless current_account and params[:id] and (request.format.json? || request.format.js? || request.format.text?)
    project = Project.accessible(current_account).find(params[:id].to_i)
    return not_found unless project
    opts = { :include_document_ids => params[:include_document_ids] != 'false' }
    @response = {'project' => project.canonical(opts)}
    json_response
  end

  # Retrieve a listing of your projects, including document id.
  def projects
    return forbidden unless current_account # already returns a 401 if credentials aren't supplied
    opts = { :include_document_ids => params[:include_document_ids] != 'false' }
    @response = {'projects' => Project.accessible(current_account).map {|p| p.canonical(opts) } }
    json_response
  end

  def create_project
    attrs = pick(params, :title, :description)
    attrs[:document_ids] = (params[:document_ids] || []).map(&:to_i)
    @response = {'project' => current_account.projects.create(attrs).canonical}
    json_response
  end

  def update_project
    data = pick(params, :title, :description, :document_ids)
    ids  = (data.delete(:document_ids) || []).map(&:to_i)
    docs = Document.accessible(current_account, current_organization).all(:conditions => {:id => ids}, :select => 'id')
    current_project.set_documents(docs.map(&:id))
    current_project.update_attributes data
    @response = {'project' => current_project.reload.canonical}
    json_response
  end

  def destroy_project
    current_project.destroy
    json nil
  end

  # Allow logging of all actions, apart from secure uploads.
  def logger
    params[:secure] ? nil : super
  end

  private

  def secure_silence_logs
    if params[:secure]
      Rails.logger.silence { yield }
    else
      yield
    end
  end

  def current_project
    @current_project ||= current_account.projects.find(params[:id].to_i)
  end

  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find_by_id(params[:id].to_i)
  end

  def current_note
    @current_note ||= Annotation.accessible(current_account).find_by_id(params[:note_id].to_i)
  end

end
