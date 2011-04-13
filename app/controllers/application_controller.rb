# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  BasicAuth = ActionController::HttpAuthentication::Basic

  protect_from_forgery

  filter_parameter_logging :password

  before_filter :set_ssl

  if Rails.env.development?
    around_filter :perform_profile
    after_filter  :debug_api
  end

  if Rails.env.production?
    around_filter :notify_exceptions
  end

  protected

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

  # If the request is asking for JSONP (eg. has a 'callback' parameter), then
  # short-circuit, and return the rendered JSONP.
  def jsonp_request?
    return false unless params[:callback]
    @callback = params[:callback]
    render :partial => 'common/jsonp.js', :type => :js
    true
  end

  # Make a JSONP-aware JSON response, using the contents of `@response`
  def json_response
    return if jsonp_request?
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
    return if BasicAuth.authorization(request).blank?
    return unless @current_account = Account.log_in(*BasicAuth.user_name_and_password(request))
    @current_organization = @current_account.organization
  end

  def admin_required
    (logged_in? && current_organization.id == 1 && !current_account.reviewer?) || forbidden
  end

  def prefer_secure
    secure_only if cookies['dc_logged_in'] == 'true'
  end

  def secure_only
    if !request.ssl? && (request.format.html? || request.format.nil?)
      redirect_to DC.server_root(:force_ssl => true) + request.request_uri
    end
  end

  def current_account
    return nil unless request.ssl?
    @current_account ||=
      session['account_id'] ? Account.find_by_id(session['account_id']) : nil
  end

  def current_organization
    return nil unless request.ssl?
    @current_organization ||=
      session['organization_id'] ? Organization.find_by_id(session['organization_id']) : nil
  end

  def handle_unverified_request
    error = RuntimeError.new "CSRF Verification Failed"
    LifecycleMailer.deliver_exception_notification(error, params)
    forbidden
  end

  def bad_request
    render :file => "#{Rails.root}/public/400.html", :status => 400
    false
  end

  # Return forbidden when the access is unauthorized.
  def forbidden
    @next = CGI.escape(request.request_uri)
    render :file => "#{Rails.root}/public/403.html", :status => 403
    false
  end

  # Return not_found when a resource can't be located.
  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404
    false
  end

  # Return server_error when an uncaught exception bubbles up.
  def server_error(e)
    render :file => "#{Rails.root}/public/500.html", :status => 500
    false
  end

  # Simple HTTP Basic Auth to make sure folks don't snoop where the shouldn't.
  def bouncer
    authenticate_or_request_with_http_basic("DocumentCloud") do |login, password|
      login == 'guest' && password == SECRETS['guest_password']
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
      ignore = e.is_a?(ActionController::UnknownAction) || e.is_a?(ActionController::RoutingError)
      LifecycleMailer.deliver_exception_notification(e, params) unless ignore
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
