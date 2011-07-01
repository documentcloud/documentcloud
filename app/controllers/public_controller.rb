class PublicController < ApplicationController

  # Public search.
  def index
    @organizations = Organization.listed
    @include_analytics = true
    render :template => 'workspace/index', :layout => 'workspace'
  end

end