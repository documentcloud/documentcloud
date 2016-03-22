# The public DocumentCloud API.
class ApiController < ApplicationController
  include DC::Access
  include DC::Search::Controller

  layout nil

  READONLY_ACTIONS = [
    :index, :search, :documents, :pending, :notes, :entities, :project, :projects, :oembed,
    :cors_options, :logger
  ]
  before_action :read_only_error, :except => READONLY_ACTIONS if read_only?

  before_action :bouncer if exclusive_access?
  before_action :prefer_secure, :only => [:index]

  skip_before_action :verify_authenticity_token

  before_action :secure_only,        :only => [:upload, :project, :projects, :upload, :destroy, :create_project, :update_project, :destroy_project]
  before_action :api_login_required, :only => [:upload, :project, :projects, :update, :destroy, :create_project, :update_project, :destroy_project]
  before_action :api_login_optional, :only => [:documents, :search, :notes, :pending, :entities]
  before_filter :maybe_set_cors_headers

  def index
    redirect_to '/help/api'
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
        @response = {
          total:    @query.total,
          page:     @query.page,
          per_page: @query.per_page,
          q:        params[:q],
          documents: @documents.map {|d| d.canonical(opts) }
        }
        render_cross_origin_json
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
        return bad_request(:error => "The 'file' parameter must be the contents of a file or a URL.")
      end
      
      if params[:file_hash] && Document.accessible(current_account, current_organization).exists?(:file_hash=>params[:file_hash])
        return conflict(:error => "This file is a duplicate of an existing one you have access to.")
      end
      params[:url] = params[:file] unless is_file
      @response = Document.upload(params, current_account, current_organization).canonical
      render_cross_origin_json
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
        redirect_to(current_document.full_text_url(direct: direct))
      end
      format.json { render_cross_origin_json }
      format.js { render_cross_origin_json }
    end
  end

  def pending
    @response = { :total_documents => Document.pending.count }
    @response[:your_documents] = current_account.documents.pending.count if logged_in?
    render_cross_origin_json
  end

  # Retrieve a note's canonical JSON.
  def notes
    return bad_request unless params[:note_id] and request.format.json? || request.format.js?
    return not_found unless current_note
    @response = {'annotation' => current_note.canonical}
    render_cross_origin_json
  end

  # Retrieve the entities for a document.
  def entities
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless current_document
    @response = {'entities' => current_document.ordered_entity_hash}
    render_cross_origin_json
  end

  def update
    return bad_request unless params[:id] and request.format.json? || request.format.js?
    return not_found unless doc = current_document
    attrs = pick(params, :access, :title, :description, :source, :related_article, :published_url, :data)
    attrs[:access] = ACCESS_MAP[attrs[:access].to_sym] if attrs[:access]
    return json(doc, 403) unless doc.secure_update attrs, current_account
    expire_pages doc.cache_paths if doc.cacheable?
    @response = {'document' => doc.canonical(:access => true, :sections => true, :annotations => true)}
    render_cross_origin_json
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
    render_cross_origin_json
  end

  # Retrieve a listing of your projects, including document id.
  def projects
    return forbidden unless current_account # already returns a 401 if credentials aren't supplied
    opts = { :include_document_ids => params[:include_document_ids] != 'false' }
    @response = {'projects' => Project.accessible(current_account).map {|p| p.canonical(opts) } }
    render_cross_origin_json
  end

  def create_project
    attrs = pick(params, :title, :description)
    attrs[:document_ids] = (params[:document_ids] || []).map(&:to_i)
    @response = {'project' => current_account.projects.create(attrs).canonical}
    render_cross_origin_json
  end

  def update_project
    data = pick(params, :title, :description, :document_ids)
    ids  = (data.delete(:document_ids) || []).map(&:to_i)
    doc_ids = Document.accessible(current_account, current_organization).where({ :id => ids }).pluck( 'id' )
    current_project.set_documents( doc_ids )
    current_project.update_attributes data
    @response = {'project' => current_project.reload.canonical}
    render_cross_origin_json
  end

  def destroy_project
    current_project.destroy
    json nil
  end

  def oembed
    # get the target url and turn it into a manipulable object.
    url = URI.parse(CGI.unescape(params[:url])) rescue nil
    return bad_request if params[:url].blank? or !url

    # Use the rails router to identify whether a URL is an embeddable resource
    resource_params = Rails.application.routes.recognize_path(url.path) rescue nil
    return not_found unless url.host == DC::CONFIG['server_root'] and resource_embeddable?(resource_params)

    controller_embed_map = {
      'annotations' => :note,
      'documents'   => :document,
      'pages'       => :page
    }

    canonical_format_map = {
      'annotations' => :js,
      'documents'   => :js,
      'pages'       => :html
    }

    resource_controller = resource_params[:controller]
    resource_url = url_for(resource_params.merge(:format => canonical_format_map[resource_controller]))

    # create a serializer mock/class/struct for temporary use
    resource_serializer_klass = Struct.new(:id, :resource_url, :type)
    resource = resource_serializer_klass.new(resource_params[:id], resource_url, controller_embed_map[resource_controller])
    
    config = pick(params, *DC::Embed.embed_klass(resource.type).config_keys)
    embed = DC::Embed.embed_for(resource, config, {:strategy => :oembed})
    
    respond_to do |format|
      format.json do
        render_cross_origin_json embed.as_json.to_json
      end
      format.all do
        # Per the oEmbed spec, unrecognized formats should trigger a 501
        not_implemented
      end
    end
  end

  def cors_options
    return bad_request unless params[:allowed_methods]
    maybe_set_cors_headers
    render :nothing => true
  end

  # Allow logging of all actions, apart from secure uploads.
  def logger
    params[:secure] ? nil : super
  end

  private

  def resource_embeddable?(resource_params)
    resource_params and
    resource_params[:id] and
    (
      (
        %w[documents pages].include?(resource_params[:controller]) and
        resource_params[:id] =~ DC::Validators::SLUG # and
        # Document.accessible(nil, nil).exists?(params[:id].to_i) 
      ) or
      (
        resource_params[:controller] == "annotations" and
        resource_params[:document_id] =~ DC::Validators::SLUG
      )
    )
  end

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
