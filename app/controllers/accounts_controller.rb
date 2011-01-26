# The AccountsController is responsible for account management -- adding users
# activating accounts, updating email addresses and the like.
class AccountsController < ApplicationController
  layout 'workspace'

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
    account.authenticate session
    key.destroy
    redirect_to '/'
  end

  # Show the "Reset Password" screen for an account holder.
  def reset
    return render if request.get?
    account = Account.lookup(params[:email].strip)
    @failure = true and return render unless account
    account.send_reset_request
    @success = true
  end

  # Requesting /accounts returns the list of accounts in your logged-in organization.
  def index
    json current_organization.accounts
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
    return forbidden unless current_account.admin?
    attributes = pick(params, :first_name, :last_name, :email, :role)
    account = Account.lookup(attributes[:email])
    if not account
      account = current_organization.accounts.create(attributes)
    elsif account.role == Account::REVIEWER
      account.role = attributes[:role]
      account.organization = current_organization
      account.save
      Annotation.update_all("organization_id = #{current_organization.id}", "account_id = #{account.id}")
    end
    account.send_login_instructions(current_account) if account.valid? and account.pending?
    json account
  end

  # Journalists are authorized to update any account in the organization.
  # Think about what the desired level of access control is.
  def update
    account   = current_organization.accounts.find(params[:id])
    is_owner  = current_account.id == account.id
    return forbidden unless account && (current_account.admin? || is_owner)
    account.update_attributes pick(params, :first_name, :last_name, :email)
    role = pick(params, :role)
    account.update_attributes(role) if !role.empty? && current_account.admin?
    password = pick(params, :password)[:password]
    if is_owner && password
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

  # Removing an account will preserve their uploaded documents, for the
  # moment -- perhaps private docs should be destroyed.
  def destroy
    current_organization.accounts.find(params[:id]).destroy
    json nil
  end

end