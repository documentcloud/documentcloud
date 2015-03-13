# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  BasicAuth = ActionController::HttpAuthentication::Basic

  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :embeddable?

  before_action :set_ssl

  if Rails.env.development?
    around_action :perform_profile
    after_action :debug_api
  end

  if Rails.env.production?
    around_action :notify_exceptions
  end

  protected

  def embeddable?
    request.format.json? or 
    request.format.jsonp? or 
    request.format.js? or
    request.format.text? or
    request.format.txt? or
    request.format.xml?
  end

  def maybe_set_cors_headers
    return unless request.headers['Origin']
    headers['Access-Control-Allow-Origin'] = request.headers['Origin']
    headers['Access-Control-Allow-Methods'] = 'OPTIONS, GET, POST, PUT, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Accept,Authorization,Content-Length,Content-Type,Cookie'
    headers['Access-Control-Allow-Credentials'] = 'true'
  end

  # Convenience method for responding with JSON. Sets the content type,
  # serializes, and allows empty responses. If json'ing an ActiveRecord object,
  # and the object has errors on it, a 409 Conflict will be returned with a
  # list of error messages.
  def json(obj, status=200)
    obj = {} if obj.nil?
    if obj.respond_to?(:errors) && obj.errors.any?
      obj = {'errors' => obj.errors.full_messages}
      status = 409
    end
    render :json => obj, :status => status
  end

  # for use by actions that may be embedded in an iframe
  # without this header IE will not send cookies
  def set_p3p_header
    # explanation of what these mean: http://www.p3pwriter.com/LRN_111.asp
    headers['P3P'] = 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"'
  end

  # If the request is asking for JSONP (eg. has a 'callback' parameter), then
  # short-circuit, and return the rendered JSONP.
  def jsonp_request?
    return false unless params[:callback]
    @callback = params[:callback]
    render :partial => 'common/jsonp.js', :content_type => 'application/javascript'
    true
  end

  # Make a JSONP-aware JSON response, using the contents of `@response`
  # Where we allow JSONP, we also allow CORS.
  def json_response
    return if jsonp_request?
    # If the request has already set the CORS headers, don't overwrite them
    # Sending the wildcard origin that will dissallow sending cookies for authentication.
    headers['Access-Control-Allow-Origin'] = '*' unless headers.has_key?('Access-Control-Allow-Origin')
    json @response
  end

  # Select only a sub-set of passed parameters. Useful for whitelisting
  # attributes from the params hash before performing a mass-assignment.
  def pick(hash, *keys)
    filtered = {}
    hash.each {|key, value| filtered[key.to_sym] = value if keys.include?(key.to_sym) }
    filtered
  end

  def logged_in?
    !!current_account
  end

  def login_required
    return true if logged_in?
    cookies.delete 'dc_logged_in'
    forbidden
  end

  def api_login_required
    authenticate_or_request_with_http_basic("DocumentCloud") do |email, password|
      return false unless @current_account = Account.log_in(email, password)
      @current_organization = @current_account.organization
      true
    end
  end

  def api_login_optional
    return if request.authorization.blank?
    return unless @current_account = Account.log_in(*BasicAuth.user_name_and_password(request))
    @current_organization = @current_account.organization
  end
  
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def admin_required
    ( logged_in? && current_account.dcloud_admin? ) || forbidden
  end

  def prefer_secure
    secure_only(302) if cookies['dc_logged_in'] == 'true'
  end

  def secure_only(status=301)
    if !request.ssl? && (request.format.html? || request.format.nil?)
      redirect_to DC.server_root(:force_ssl => true) + request.original_fullpath, :status => status
    end
  end

  def current_account
    return nil unless request.ssl?
    @current_account ||=
      session['account_id'] ? Account.active.find_by_id(session['account_id']) : nil
  end

  def current_organization
    return nil unless request.ssl?
    @current_organization ||=
      session['organization_id'] ? Organization.find_by_id(session['organization_id']) : nil
  end

  def handle_unverified_request
    error = RuntimeError.new "CSRF Verification Failed"
    LifecycleMailer.exception_notification(error, params).deliver
    forbidden
  end

  def bad_request
    render :file => "#{Rails.root}/public/400.html", :status => 400
    false
  end

  # Return forbidden when the access is unauthorized.
  def forbidden
    @next = CGI.escape(request.original_url)
    respond_to do |format|
      format.js  { json({:error=>"Forbidden"}, 403) }
      format.json{ json({:error=>"Forbidden"}, 403) }
      format.any { render :file => "#{Rails.root}/public/403.html", :status => 403 }
    end
    false
  end

  # Return not_found when a resource can't be located.
  def not_found
    respond_to do |format|
      format.js  { json({:error=>"Not Found"}, 404) }
      format.json{ json({:error=>"Not Found"}, 404) }
      format.any { render :file => "#{Rails.root}/public/404.html", :status => 404 }
    end
    false
  end

  # Return server_error when an uncaught exception bubbles up.
  def server_error(e)
    respond_to do |format|
      format.js  { json({:error=>"Internal Server Error (sorry)"}, 500) }
      format.json{ json({:error=>"Internal Server Error (sorry)"}, 500) }
      format.any { render :file => "#{Rails.root}/public/500.html", :status => 500 }
    end
    false
  end

  # Simple HTTP Basic Auth to make sure folks don't snoop where the shouldn't.
  def bouncer
    authenticate_or_request_with_http_basic("DocumentCloud") do |login, password|
      login == DC::SECRETS['guest_username'] && password == DC::SECRETS['guest_password']
    end
  end

  def set_ssl
    Thread.current[:ssl] = request.ssl?
  end

  # Email production exceptions to us. Once every 2 minutes at most, per process.
  def notify_exceptions
    begin
      yield
    rescue Exception => e
      ignore = e.is_a?(AbstractController::ActionNotFound) || e.is_a?(ActionController::RoutingError)
      LifecycleMailer.exception_notification(e, params).deliver unless ignore
      raise e
    end
  end

  # In development mode, optionally perform a RubyProf profile of any request.
  # Simply pass perform_profile=true in your params.
  def perform_profile
    return yield unless params[:perform_profile]
    require 'ruby-prof'
    RubyProf.start
    yield
    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    File.open("#{Rails.root}/tmp/profile.txt", 'w+') do |f|
      printer.print(f)
    end
  end

  # Return all requests as text/plain, if a 'debug' param is passed, to make
  # the JSON visible in the browser.
  def debug_api
    response.content_type = 'text/plain' if params[:debug]
  end

end
