class Accounts:OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def circlet
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = Account.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "DocumentCloud") if is_navigational_format?
    else
      session["devise.documentcloud_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
