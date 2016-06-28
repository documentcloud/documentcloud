class AuthenticationController < ApplicationController

  before_action :bouncer, :except => [:callback] if exclusive_access?

  skip_before_action :verify_authenticity_token, :only => [:login]
  after_action :allow_iframe, :only=>[:iframe,:inner_iframe,:iframe_success,:iframe_logout]

  before_action :secure_only,     :only => [:login, :logout]
  
  READONLY_ACTIONS = [
    :signup_info, :login, :logout, :blank, :remote_data
  ]
  before_action :read_only_error, :except => READONLY_ACTIONS if read_only?

  # Display the signup information page.
  def signup_info
    render :layout => 'workspace'
  end

  # /login handles both the login form and the login request.
  def login
    return redirect_to '/' if current_account && current_account.refresh_credentials(cookies) && !current_account.reviewer? && current_account.active?
    return render(:layout => 'workspace') unless request.post?
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
    clear_login_state
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

  layout 'embedded_login', :only=>[ :inner_iframe, :iframe_success, :iframe_failure, :popup_completion, :iframe_logout,:callback,:request_additional_information ]

  before_action :login_required, :only => [:iframe_success,:record_user_information]
  before_action :set_p3p_header

  # this is needed for running omniauth on rails 2.3.  Without it the route
  # causes an error even though omniauth is intercepting it
  def blank; render :plain => "Not Found.", :status => 404 end

  # this is the endpoint for an embedded document to obtain addition information
  # about the document as well as the current user
  def remote_data
    render :json => build_remote_data( params[:document_id] )
  end

  # Closes the popup window and loads the appropriate page
  # into the inner iframe that opened them
  def popup_completion
    session.delete(:omniauth_popup_next)
  end

  # Renders a very minimialist page with only
  # an iframe inside it, and establishes a XDM RPC socket
  # which acts as a provider to the cross-site requestor
  #
  # The iframe loads content from the inner_iframe action below
  def iframe
  end

  def iframe_logout
    clear_login_state
    flash[:notice] = 'You have logged out successfully'
    @remote_data = build_remote_data( params[:document_id] )
    @status = false
    render :action=>'iframe_login_status'
  end

  # Displays the login page inside an iframe.
  #
  # if they are already logged in, display a success message,
  # otherwise renders the standard login page template inside our
  # own minimalistic layout using custom css to compact it.
  def inner_iframe
    if logged_in?
      @account = current_account
      flash[:notice] = 'You have successfully logged in'
      @remote_data = build_remote_data( params[:document_id] )
      @status = true
      render :action=>'iframe_login_status'
    else
      @next_url = '/auth/iframe_success'
      session[:dv_document_id]=params[:document_id]
      render :template=>'authentication/social_login'
    end
  end

  # Set the iframe session flag before loading the service from omniauth
  # This way we can know where the request originated and can close the popup
  # after the authentication completes
  def omniauth_start_popup
    session[:omniauth_popup_next]='/auth/popup_completion'
    redirect_to params[:service]
  end

  # renders the message and communicates the success back to the outer
  # iframe and across the xdm socket to the viewer
  def iframe_success
    @remote_data = session.has_key?(:dv_document_id) ? build_remote_data( session.delete(:dv_document_id) ) : {}
    flash[:notice] = 'Successfully logged in'
    @status = true
    render :action=>'iframe_login_status'
  end

  # Where third-party logins come back to once they have
  # completed successfully.
  def callback
    if logged_in?
      # if logged in, then they are adding a new account identity
      current_account.record_identity_attributes( identity_hash ).save!
      @account = current_account
    else
      @account = Account.from_identity( identity_hash )
    end
    if @account.errors.empty?
      @account.authenticate(session, cookies)
      @next_url = session[ :omniauth_popup_next ] || request.env['omniauth.origin'] || '/'
      render :action=>:request_additional_information
    else
      flash[:error] = @account.errors.full_messages.to_sentence
      render :action=>:login
    end
  end

  def record_user_information
    account = current_account
    account.update_attributes( pick(params, :first_name, :last_name) )
    if account.errors.empty?
      redirect_to params[:next_url]
    else
      flash[:error] = account.errors.full_messages.to_sentence
      render :action=>:request_additional_information
    end
  end

  # The destination for third party logins that have failed.
  # In almost all cases this is due to the cancel option
  # being selected while on the external site
  def failure
    flash[:error] = params[:message]
    redirect_to :action=>'login'
  end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  # convenience method to extract the omniauth identity data
  def identity_hash
    request.env['omniauth.auth']
  end


  def build_remote_data( document_id )
    data = { :document => {} }

    if logged_in?
      data[:account] = current_account.canonical
      if document = Document.accessible(current_account,current_organization).find( document_id )
        data[:document][:annotations_url] = document.annotations_url if document.commentable?( current_account )
        data[:document][:annotations]     = document.annotations_with_authors( current_account ).map do | note |
          note.canonical.merge({ :editable=> current_account.owns?( note ) })
        end
      end
    end

    return data
  end

end
