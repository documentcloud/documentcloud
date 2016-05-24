class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def dc_auth
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
 
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "DocumentCloud"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.dc_auth_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    flash[:error] = params[:message]
    redirect_to home_path
  end
end
