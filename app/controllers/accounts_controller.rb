# The AccountsController is responsible for account management -- adding users
# activating accounts, updating email addresses and the like.
class AccountsController < ApplicationController
  layout 'workspace'

  before_filter :secure_only, :only => [:enable, :reset]
  before_filter :login_required, :except => [:enable, :reset, :logged_in]
  before_filter :bouncer, :only => [:enable, :reset] if Rails.env.staging?

  # Enabling an account continues the second half of the signup process,
  # allowing the journalist to set their password, and logging them in.
  def enable
    return render if request.get?
    @failure = 'Please accept the Terms of Service.' and return render unless params[:acceptance]
    key = SecurityKey.find_by_key(params[:key])
    @failure = 'The account is invalid, or has already been activated.' and return render unless key
    account = key.securable
    account.password = params[:password]
    account.save
    account.authenticate(session, cookies)
    key.destroy
    redirect_to '/'
  end

  # Show the "Reset Password" screen for an account holder.
  def reset
    return render if request.get?
    @display_notice = true
    account = Account.lookup(params[:email].strip)
    @failure = true and return render unless account
    account.send_reset_request
    @success = true
  end

  # Requesting /accounts returns the list of accounts in your logged-in organization.
  def index
    json current_organization.accounts.active
  end

  # Does the current request come from a logged-in account?
  def logged_in
    return bad_request unless request.format.json? or request.format.js?
    @response = {:logged_in => logged_in?}
    json_response
  end

  # Creating a new account creates a pending account, with a security key
  # instead of a password.
  def create
    return forbidden unless current_account.admin? or params[:role] == Account::REVIEWER
    attributes = pick(params, :first_name, :last_name, :email, :role)
    account = Account.lookup(attributes[:email])
    if account.nil?
      account = current_organization.accounts.create(attributes)
    elsif account.reviewer?
      account.upgrade_reviewer_to_real(current_organization, attributes[:role])
    elsif account.role == Account::DISABLED
      return json({:errors => ['That email address belongs to an inactive account.']}, 409)
    else
      return json(nil, 409)
    end
    account.send_login_instructions(current_account) if account.valid? && account.pending?
    json account
  end

  # Journalists are authorized to update any account in the organization.
  # Think about what the desired level of access control is.
  def update
    account = current_organization.accounts.find(params[:id])
    return json(nil, 403) unless account && current_account.allowed_to_edit_account?(account)
    account.update_attributes pick(params, :first_name, :last_name, :email)
    role = pick(params, :role)
    account.update_attributes(role) if !role.empty? && current_account.admin?
    password = pick(params, :password)[:password]
    if (current_account.id == account.id) && password
      account.password = password
      account.save
    end
    json account
  end

  # Resend a welcome email for a pending account.
  def resend_welcome
    return forbidden unless current_account.admin?
    account = current_organization.accounts.find(params[:id])
    LifecycleMailer.deliver_login_instructions account, current_account
    json nil
  end

  # Removing an account only changes their role so that they cannot
  # login. Ther documents, projects, and name remain.
  def destroy
    return forbidden unless current_account.admin?
    account = current_organization.accounts.find(params[:id])
    account.update_attributes :role => Account::DISABLED
    json nil
  end

end