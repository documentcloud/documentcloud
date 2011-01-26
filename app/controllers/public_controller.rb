class PublicController < ApplicationController

  # Public search.
  def index
    return redirect_to("/public/") unless request.path.match(/\/$/)
    @organizations = Organization.listed
    @include_analytics = true
    render :template => 'workspace/index', :layout => 'workspace'
  end

end