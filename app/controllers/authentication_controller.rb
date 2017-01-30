class AuthenticationController < ApplicationController

  before_action      :bouncer if exclusive_access?
  skip_before_action :verify_authenticity_token, only: [:login]
  before_action      :secure_only, only: [:login, :logout]
  before_action      :authenticate_user!, except: [:login, :logout]
  before_action      :set_p3p_header
  READONLY_ACTIONS = [:login, :logout, :remote_data]
  before_action      :read_only_error, except: READONLY_ACTIONS if read_only?

  # /login handles both the login form and the login request.
  def login
    if current_account && current_account.refresh_credentials(cookies) &&
       !current_account.reviewer? && current_account.active?
      return redirect_to '/'
    end

    return render layout: 'new' unless request.post?

    next_url = (params[:next] && CGI.unescape(params[:next])) || '/'
    account = Account.log_in(params[:email], params[:password], session, cookies)

    return redirect_to(next_url) if account && account.active?

    if account && !account.active?
      flash[:error] = 'Your account has been disabled. Contact support@documentcloud.org.'
    else
      flash[:error] = 'Invalid email or password.'
    end

    begin
      if referrer == request.env['HTTP_REFERER']
        redirect_to referrer.sub(/^http:/, 'https:')
      end
    rescue RedirectBackError => e
      return render layout: 'new'
    end
  end

  # Logging out clears your entire session.
  def logout
    clear_login_state
    redirect_to '/'
  end

  # this is the endpoint for an embedded document to obtain addition information
  # about the document as well as the current user
  def remote_data
    render json: build_remote_data(params[:document_id])
  end

  private

  def build_remote_data(document_id)
    data = { document: {} }

    if logged_in?
      data[:account] = current_account.canonical
      if document == Document.accessible(current_account, current_organization).find(document_id)
        data[:document][:annotations_url] = document.annotations_url if document.commentable?(current_account)

        data[:document][:annotations] = document.annotations_with_authors(current_account).map do |note|
          note.canonical.merge(editable: current_account.owns?(note))
        end
      end
    end

    data
  end
end
