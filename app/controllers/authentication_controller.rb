class AuthenticationController < ApplicationController

  # Display the signup information page.
  def signup_info
  end

  # /login handles both the login form and the login request.
  def login
    return redirect_to '/' if current_account && current_account.refresh_credentials(cookies) && !current_account.reviewer? && current_account.active?
    return render(:layout => "workspace") unless request.post?
    next_url = (params[:next] && CGI.unescape(params[:next])) || '/'
    account = Account.log_in(params[:email], params[:password], session, cookies)
    return redirect_to(next_url) if account && account.active?
    if account && !account.active?
      flash[:error] = "Your account has been disabled. Contact support@documentcloud.org."
    else
      flash[:error] = "Invalid email or password."
    end
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

# This controller deals with the concept of identities which are provided/verified
# by either a documentcloud account or third party service
# such as Twiter, Facebook, or Google Account
#
# It supports logging in via either the normal documentcloud login methods
# or by using an iframe embedded inside an external website
#
# Logging in via an iframe is a complicated affair.
#
# The flow is:
#
#  An initial iframe is requested at /auth/iframe.
#  This iframe loads up the easyXDM JS library (http://easyxdm.net/wp/) and
#  establishes an RPC socket and stores the reference into the window scope.
#
#  The first hurdle is that XDM requires that the url of the iframe not change
#  Therefore it's not possible to prerform a normal login inside the iframe.
#
#  To get around this restriction a second iframe is nested inside the parent (xdm'ed) iframe.
#  The child iframe can:
#    * Navigate to different urls, allowing it to perform a login process
#    * It can also communicate back to the parent via the DOM window.parent object, and from there
#      access the RPC socket at window.parent.socket
#
#  An additional hurdle is that third party identity services disallow loading inside an iframe
#  by using the X-Frame-Options http header.
#
#  To overcome this restriction clicks on the third-party login links are intercepted and:
#    * A pop-up window is opened with the initial url of /auth/omniauth_start_popup
#    * The method associated with that url flags the session and issues a redirect to the appropriate service
#    * Once the omniauth flow is complete, the popup notifies the iframe is notified using the DOM window.opener
#

  layout 'embedded_login', :only=>[ :inner_iframe, :iframe_success, :iframe_failure, :popup_completion ]

  before_filter :login_required, :only => [:iframe_success]

  # this is needed for running omniauth on rails 2.3.  Without it the route
  # causes an error even though omniauth is intercepting it
  def blank; render :text => "Not Found.", :status => 404 end


  # Closes the popup window and loads the appropriate page 
  # into the inner iframe that opened them
  def popup_completion
  end

  # Renders a very minimialist page with only
  # an iframe inside it, and establishes a XDM RPC socket
  # which acts as a provider to the cross-site requestor
  #
  # The iframe loads content from the inner_iframe action below
  def iframe
  end

  # Displays the login page inside an iframe.
  #
  # if they are already logged in, display a success message,
  # otherwise renders the standard login page template inside our
  # own minimalistic layout using custom css to compact it.
  def inner_iframe
    if logged_in?
      @account = current_account
      flash[:notice] = 'You are already logged in'
      render :action=>'iframe_success'
    else
      @next_url = '/auth/iframe_success'
      render :template=>'workspace/login'
    end
  end

  # Set the iframe session flag before loading the service from omniauth
  # This way we can know where the request originated and can close the popup
  # after the authentication completes
  def omniauth_start_popup
    session[:omniauth_from_popup]=true
    redirect_to params[:service]
  end

  # renders the message and communicates the success back to the outer
  # iframe and across the xdm socket to the viewer
  def iframe_success
    @account = current_account
    flash[:notice] = 'Successfully logged in'
  end
  # Displays flash[:error], Relays the failure across XDM RPC
  def iframe_failure
  end

  
  # Where third-party logins come back to once they have
  # completed successfully.
  def callback
    if logged_in?
      # if logged in, then they are adding a new account identity
      current_account.record_identity_attributes( identity_hash ).save!
    else
      account = Account.from_identity( identity_hash )
      if account.errors.empty?
        account.authenticate(session, cookies)
      else
        flash[:error] = account.errors.full_messages.to_sentence
      end
    end
    flash[:notice] = "Successfully logged in."
    render_or_redirect( true )
  end

  # The destination for third party logins that have failed.  
  # In almost all cases this is due to the cancel option 
  # being selected while on the external site
  def failure
    flash[:error] = params[:message]
    render_or_redirect( false )
  end

  private

  # common method called in cases of both success and failure by the 
  # omniauth callback
  def render_or_redirect( was_successful )
    # if we started from an iframe and the user authenticated via omniauth
    # then the request will come from a popup window.  
    #
    # The popup views will close it and display the results 
    # inside the iframe that opened the window
    if ( session.delete( :omniauth_from_popup ) )
      @message = was_successful ? 'success' : 'failure'
      render :action => 'popup_completion', :layout=>'embedded_login'
    else
      redirect_to request.env['omniauth.origin'] || '/'
    end
  end

  # convenience method to extract the omniauth identity data
  def identity_hash
    request.env['omniauth.auth']
  end


end
