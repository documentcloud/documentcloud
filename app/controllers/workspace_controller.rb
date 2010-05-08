class WorkspaceController < ApplicationController

  RESULTS_REQUEST = /\A\/results/

  before_filter :bouncer, :except => :index if Rails.env.staging?

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index
    if current_organization && current_account
      @projects         = current_account.projects.all(:include => ['project_memberships'])
      @document_count   = Document.owned_by(current_account).count
      @annotation_count = Annotation.owned_by(current_account).count
      return
    end
    return redirect_to('/home') # unless request.headers['Authorization']
    render :action => 'home', :layout => 'empty'
  end

  def home
    render :action => 'home', :layout => 'empty'
  end

  # Display the signup information page.
  def signup_info
  end

  # /login handles both the login form and the login request.
  def login
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

  def results_request?
    !!request.path.match(RESULTS_REQUEST)
  end

end