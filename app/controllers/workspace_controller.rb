class WorkspaceController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:login]

  before_filter :bouncer, :except => :index if Rails.env.staging?

  before_filter :prefer_secure, :only => [:index]
  before_filter :secure_only,   :only => [:login]

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index
    if logged_in? && !current_account.reviewer?
      @accounts = current_organization.accounts.real
      @projects = Project.load_for(current_account)
      @organizations = Organization.all
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
    return redirect_to '/' if current_account && current_account.refresh_credentials(cookies)
    return render unless request.post?
    next_url = (params[:next] && CGI.unescape(params[:next])) || '/'
    return redirect_to next_url if Account.log_in(params[:email], params[:password], session, cookies)
    flash[:error] = true
    begin
      if referrer = request.env["HTTP_REFERER"]
        redirect_to referrer.sub(/^http:/, 'https:')
      end
    rescue RedirectBackError => e
      # Render...
    end
  end

  # Logging out clears your entire session.
  def logout
    reset_session
    cookies.delete 'dc_logged_in'
    redirect_to '/'
  end

end