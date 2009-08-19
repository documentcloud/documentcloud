# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  around_filter :perform_profile if Rails.development?
    
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
