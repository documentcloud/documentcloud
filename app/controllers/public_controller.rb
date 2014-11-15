class PublicController < ApplicationController
  
  before_action :secure_only

  # Public search.
  def index
    @organizations = Organization.listed
    # commented out for now, because the workspace determines
    # whether it's in public search solely based on the presence
    # of dc.account
    # 
    # as a consequence, when in the public search, logged in users
    # will not be able to tell from the login links that they are
    # logged in.
    #@current_account = current_account
    @include_analytics = true
    render :template => 'workspace/index', :layout => 'workspace'
  end

end