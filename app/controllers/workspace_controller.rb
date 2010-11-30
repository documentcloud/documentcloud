class WorkspaceController < ApplicationController

  before_filter :bouncer, :except => :index if Rails.env.staging?

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index
    if logged_in?
      @accounts = current_organization.accounts.contributors
      @projects = Project.load_for(current_account)
      @organizations = []
      @has_documents = Document.owned_by(current_account).count(:limit => 1) > 0
      return
    end
    return redirect_to('/home')
    render :action => 'home', :layout => 'empty'
  end

  def home
    render :action => 'home', :layout => 'empty'
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
    return redirect_to '/' if current_account
    return render unless request.post?
    account = Account.log_in(params[:email], params[:password], session)
    account ? redirect_to('/') : fail(true)
  end

  # Logging out clears your entire session.
  def logout
    reset_session
    redirect_to '/'
  end


  private

  def fail(message)
    @failure = message
  end

end