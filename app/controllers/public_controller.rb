class PublicController < ApplicationController

  # Public search.
  def index
    @organizations = Organization.listed
    @current_account = current_account
    @include_analytics = true
    render :template => 'workspace/index', :layout => 'workspace'
  end

end