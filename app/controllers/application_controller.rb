# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  around_filter :perform_profile if Rails.development?
  
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
  
  # Select only a sub-set of passed parameters. Useful for whitelisting 
  # attributes from the params hash before performing a mass-assignment.
  def pick_params(*keys)
    filtered = {}
    params.each {|key, value| filtered[key] = value if keys.include?(key.to_sym) }
    filtered
  end
  
  def logged_in?
    session['account_id'] && session['organization_id']
  end 
  
  def login_required
    logged_in? || forbidden
  end
  
  def current_account
    return nil unless session['account_id']
    @current_account ||= Account.find(session['account_id'])
  end
  
  def current_organization
    return nil unless session['organization_id']
    @current_organization ||= Organization.find(session['organization_id'])
  end
  
  # Return forbidden when the access is unauthorized.
  def forbidden
    render :file => "#{RAILS_ROOT}/public/403.html", :status => 403
    false
  end
  
  # Return not_found when a resource can't be located.
  def not_found  
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404  
    false
  end  
  
  # Return server_error when an uncaught exception bubbles up.
  def server_error(e)
    render :file => "#{RAILS_ROOT}/public/500.html", :status => 500
    false
  end
  
  # Simple HTTP Basic Auth to make sure folks don't snoop where the shouldn't.
  def bouncer
    authenticate_or_request_with_http_basic("DocumentCloud Staging") do |login, password|
      return true if (login == 'main'  && password == 'REDACTED') ||
                     (login == 'guest' && password == 'REDACTED')
      forbidden
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
    File.open("#{RAILS_ROOT}/tmp/profile.txt", 'w+') do |f|
      printer.print(f)
    end
  end
  
end
