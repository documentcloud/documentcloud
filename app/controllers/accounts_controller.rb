# The AccountsController is responsible for account management -- adding users
# activating accounts, updating email addresses and the like.
class AccountsController < ApplicationController
  layout 'workspace'

  before_filter :login_required, :except => [:enable, :reset]
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
    account = Account.lookup(params[:email])
    @failure = true and return render unless account
    account.send_reset_request
    @success = true
  end

  # Requesting /accounts returns the list of accounts in your logged-in organization.
  def index
    json 'accounts' => current_organization.accounts
  end

  # Creating a new account creates a pending account, with a security key
  # instead of a password.
  # TODO: We can't sent email from EC2 without it getting flagged as spam.
  def create
    return forbidden unless current_account.admin?
    attributes = pick(:json, :first_name, :last_name, :email, :role)
    account = current_organization.accounts.create(attributes)
    account.send_login_instructions(current_account)
    json account
  end

  # Journalists are authorized to update any account in the organization.
  # Think about what the desired level of access control is.
  def update
    account   = current_organization.accounts.find(params[:id])
    is_owner  = current_account.id == account.id
    return forbidden unless account && (current_account.admin? || is_owner)
    account.update_attributes pick(:json, :first_name, :last_name, :email)
    role = pick(:json, :role)
    account.update_attributes(role) if !role.empty? && current_account.admin?
    password = pick(:json, :password)[:password]
    if is_owner && password
      account.password = password
      account.save
    end
    json account
  end

  # Removing an account will preserve their uploaded documents, for the
  # moment -- perhaps private docs should be destroyed.
  def destroy
    current_organization.accounts.find(params[:id]).destroy
    json nil
  end

end