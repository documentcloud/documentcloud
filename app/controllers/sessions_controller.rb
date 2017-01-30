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
    session[:organization_id] = organization ? organization.id : account.default_membership.organization

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

  def switch_membership_by_organization
    membership = current_account.memberships.where(organization_id: params[:organization_id]).last
    unless membership
      flash[:error] = 'You don’t seem to be a member of that organization.'
      redirect_to workspace_url and return
    end
    current_account.set_default_membership(membership)
    session[:membership_id]   = membership.id
    session[:organization_id] = membership.organization_id
    # Slug format has been de facto validated by route constraint
    redirect_to workspace_url(query: "Group:#{params[:organization_slug]}")
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
