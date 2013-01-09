class IdentitiesController < ApplicationController

  def callback
    if logged_in?
      # if logged in, then they are adding a new account identity
      current_account.record_identity_info( identity_hash ).save!
    else
      account = Account.from_identity( identity_hash )
      if account.errors.empty?
        account.authenticate(session, cookies)
      else
        flash[:error] = account.errors.full_messages.to_sentence
      end
    end
    redirect_to request.env['omniauth.origin'] || '/'
  end


  def failure
    flash[:error] = params[:message]
    redirect_to params[:origin] || '/'
  end


  private
  def identity_hash
    request.env['omniauth.auth']
  end

end
