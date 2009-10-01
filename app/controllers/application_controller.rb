# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  around_filter :perform_profile if Rails.development?
  
  protected
  
  # Convenience method for responding with JSON. Sets the content type, 
  # serializes, and allows empty responses.
  def json(obj)
    return head :no_content if obj.nil?
    render :json => obj
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
  
  # Simple auth for now...
  def authenticate
    authenticate_or_request_with_http_basic("DocumentCloud Staging") do |login, password|
      return true if login == 'main' && password == 'REDACTED'
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
