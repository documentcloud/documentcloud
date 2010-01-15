# This new version of the workspace will replace the original
# WorkspaceController when it's finished.
class DesignController < ApplicationController

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index
    return redirect_to('/home') unless current_organization && current_account
  end

end