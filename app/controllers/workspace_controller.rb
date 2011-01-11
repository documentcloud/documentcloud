class WorkspaceController < ApplicationController

  before_filter :bouncer, :except => :index if Rails.env.staging?

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index
    if logged_in?
      return redirect_to('/home') if current_account.reviewer?
      @accounts = current_organization.accounts.contributors
      @projects = Project.load_for(current_account)
      @organizations = []
      @has_documents = Document.owned_by(current_account).count(:limit => 1) > 0
      return
    end
    redirect_to '/home'
  end

  # Page for unsupported browsers, to request an upgrade.
  def upgrade
    render :layout => false
  end

  # Display the signup information page.
  def signup_info
  end

  # /login handles both the login form and the login request.
  def login
    return redirect_to '/' if current_account && !current_account.reviewer?
    return render unless request.post?
    return redirect_to '/' if Account.log_in(params[:email], params[:password], session)
    flash[:error] = true
    begin
      redirect_to :back
    rescue RedirectBackError => e
      # Render...
    end
  end

  # Logging out clears your entire session.
  def logout
    reset_session
    redirect_to '/'
  end

end