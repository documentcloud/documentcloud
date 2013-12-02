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
  # consider extracting the HTML info into a single method in common w/ workspace
  def index
    respond_to do |format|
      format.html do
        if logged_in?
          if current_account.real?
            @projects = Project.load_for(current_account)
            @current_organization = current_account.organization
            @organizations = Organization.all_slugs
            @has_documents = Document.owned_by(current_account).count(:limit => 1) > 0
            return render :layout => 'workspace'
          else
            return redirect_to '/public/search'
          end
        end
        redirect_to '/home'
      end
      format.json do 
        json current_organization.accounts.active
      end
    end
  end

  # Does the current request come from a logged-in account?
  def logged_in
    return bad_request unless request.format.json? or request.format.js?
    @response = {:logged_in => logged_in?}
    json_response
  end

  # Fetches or creates a user account and creates a membership for that
  # account in an organization.
  # 
  # New accounts are created as pending, with a security key instead of
  # a password.
  def create
    # Check the requester's permissions
    return forbidden unless current_account.admin? or 
      (current_account.real?(current_organization) and params[:role] == Account::REVIEWER)

    # Find or create the appropriate account
    account_attributes = pick(params, :first_name, :last_name, :email, :language, :document_language)
    account = Account.lookup(account_attributes[:email]) || Account.create(account_attributes)    

    # Find role for account in organization if it exists.
    membership_attributes = pick(params, :role, :concealed)
    membership = current_organization.role_of(account)
    
    # Create a membership if account has no existing role
    if membership.nil?
      membership_attributes[:default] = true unless account.memberships.exists?
      membership = current_organization.memberships.create(membership_attributes.merge(:account_id => account.id))
    elsif membership.role == Account::REVIEWER # or if account is a reviewer in this organization
      account.upgrade_reviewer_to_real(current_organization, membership_attributes[:role])
    elsif membership.role == Account::DISABLED
      return json({:errors => ['That email address belongs to an inactive account.']}, 409)
    else
      return json({:errors => ['That email address is already part of this organization']}, 409)
    end

    if account.valid?
      if account.pending?
        account.send_login_instructions(current_account)
      else
        LifecycleMailer.deliver_membership_notification(account, current_organization, current_account)
      end
    end
    json account.canonical( :membership=>membership )
  end

  # Journalists are authorized to update any account in the organization.
  # Think about what the desired level of access control is.
  def update
    account = current_organization.accounts.find(params[:id])
    return json(nil, 403) unless account && current_account.allowed_to_edit_account?(account, current_organization)
    unless account.update_attributes pick(params, :first_name, :last_name, :email,:language, :document_language)
      return json({ "errors" => account.errors.to_a.map{ |field, error| "#{field} #{error}" } }, 409)
    end
    role = pick(params, :role)
    #account.update_attributes(role) if !role.empty? && current_account.admin?
    membership = current_organization.role_of(account)
    membership.update_attributes(role) if !role.empty? && current_account.admin?
    password = pick(params, :password)[:password]
    if (current_account.id == account.id) && password
      account.password = password
      account.save
    end
    json account.canonical( :membership=>membership )
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
