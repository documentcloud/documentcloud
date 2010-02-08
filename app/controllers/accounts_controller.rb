# The AccountsController is responsible for account management -- adding users
# activating accounts, updating email addresses and the like.
class AccountsController < ApplicationController
  layout 'workspace'

  before_filter :login_required, :except => [:enable]
  before_filter :bouncer, :only => [:enable] unless Rails.env.development?

  # Enabling an account continues the second half of the signup process,
  # allowing the journalist to set their password, and logging them in.
  def enable
    return render if request.get?
    key = SecurityKey.find_by_key(params[:key])
    @failure = true and return render unless key
    account = key.securable
    account.password = params[:password]
    account.save
    account.authenticate(session)
    key.destroy
    redirect_to '/'
  end

  # Requesting /accounts returns the list of accounts in your logged-in organization.
  def index
    json 'accounts' => current_organization.accounts
  end

  # Creating a new account creates a pending account, with a security key
  # instead of a password.
  # TODO: We can't sent email from EC2 without it getting flagged as spam.
  def create
    attributes = pick(:json, :first_name, :last_name, :email)
    account = current_organization.accounts.create(attributes)
    account.send_login_instructions
    json account
  end

  # Journalists are authorized to update any account in the organization.
  # Think about what the desired level of access control is.
  def update
    account = current_organization.accounts.find(params[:id])
    account.update_attributes pick(:json, :first_name, :last_name, :email)
    json account
  end

  # Removing an account will preserve their uploaded documents, for the
  # moment -- perhaps private docs should be destroyed.
  def destroy
    current_organization.accounts.find(params[:id]).destroy
    json nil
  end

end