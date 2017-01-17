class SessionsController < ApplicationController

  def new
    redirect_to '/auth/documentcloud'
  end

  def create
    account = Account.find_or_create_from_auth_hash(auth_hash)
    # TODO: update me with org switcher
    organization = Organization.find_first_organization_for_auth(account)

    # render text: auth_hash.inspect

    reset_session

    session[:account_id]      = account.id
    session[:membership_id]   = account.default_membership.id
    session[:organization_id] = organization.id

    # current_account
    # # render nothing: true

    if current_account && current_account.refresh_credentials(cookies) &&
       !current_account.reviewer? && current_account.active?
      return redirect_to '/'
    end

    #return render layout: 'new' unless request.post?

    # next_url = (params[:next] && CGI.unescape(params[:next])) || '/'
    # account = Account.log_in(params[:email], params[:password], session, cookies)
    account.authenticate(session, cookies) if session && cookies
    # return redirect_to(next_url) if account && account.active?

    if account && !account.active?
      flash[:error] = 'Your account has been disabled. Contact support@documentcloud.org.'
    else
      flash[:error] = 'Invalid email or password.'
    end

    # begin
    #   if referrer == request.env['HTTP_REFERER']
    #     redirect_to referrer.sub(/^http:/, 'https:')
    #   end
    # rescue RedirectBackError => e
    #   return render layout: 'new'
    # end
    redirect_to home_path
  end

  def switch_membership
    return forbidden unless membership = current_account.memberships.find(params[:membership_id])
    session[:membership_id]   = membership.id
    session[:organization_id] = membership.organization_id
  end

  # NB: This should only be used temporarily or sparingly; `switch_membership` 
  # is preferred
  def switch_membership_by_organization
    return forbidden unless membership = current_account.memberships.where(organization_id: params[:organization_id]).last
    session[:membership_id]   = membership.id
    session[:organization_id] = membership.organization_id
  end

  def destroy
    reset_session
    redirect_to home_path
  end

  def failure
    # render text: auth_hash.inspect
    flash[:error] = params[:message].humanize
    redirect_to home_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
