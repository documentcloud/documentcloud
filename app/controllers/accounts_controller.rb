# The AccountsController is responsible for account management -- adding users
# activating accounts, updating email addresses and the like.
class AccountsController < ApplicationController
  layout 'new'

  before_action :secure_only,    only: [:enable, :reset]
  before_action :login_required, except: [:enable, :reset, :logged_in]
  before_action :bouncer,        only: [:enable, :reset] if exclusive_access?

  READONLY_ACTIONS = [
    :index, :logged_in, :resend_welcome
  ]
  before_action :read_only_error, except: READONLY_ACTIONS if read_only?

  # Enabling an account continues the second half of the signup process,
  # allowing the journalist to set their password, and logging them in.
  def enable
    key = SecurityKey.find_by_key(params[:key])
    if key
      if request.post?
        if params[:acceptance] == 'yes'
          account = key.securable
          account.update(password: params[:password])
          account.authenticate(session, cookies)
          key.destroy
          redirect_to homepage_url and return
        else
          flash.now[:error] = 'Please accept the Terms of Service.'
        end
      end
    else
      redirect_to login_url, flash: {error: 'That account is invalid or has already been activated.'} and return
    end
  end

  # Show the "Reset Password" screen for an account holder.
  def reset
    if request.post? && params[:email].present?
      if account = Account.lookup(params[:email].strip)
        account.send_reset_request
      end
      # Show this flash whether or not the email address exists in our system.
      flash.now[:notice] = "Please check the email address you provided for further instructions."
    end
  end

  # Requesting /accounts returns the list of accounts in your logged-in organization.
  # consider extracting the HTML info into a single method in common w/ workspace
  def index
    respond_to do |format|
      format.html do
        if logged_in? and current_account.real?
          @projects = Project.load_for(current_account)
          @current_organization = current_account.organization
          @organizations = Organization.all_slugs
          @has_documents = Document.owned_by(current_account).exists?
          return render template: 'workspace/index', layout: 'workspace'
        end
        redirect_to public_search_url(query: params[:query])
      end
      format.json do
        json current_organization.accounts.active
      end
    end
  end

  # Does the current request come from a logged-in account?
  def logged_in
    return bad_request unless request.format.json? or request.format.js?
    @response = { logged_in: logged_in? }
    render_cross_origin_json
  end

  # Fetches or creates a user account and creates a membership for that
  # account in an organization.
  #
  # New accounts are created as pending, with a security key instead of
  # a password.
  def create
    # Check the requester's permissions
    return forbidden unless current_account.admin?(current_organization) or
      (current_account.real?(current_organization) and params[:role] == Account::REVIEWER)

    # Find or create the appropriate account
    account_attributes = pick(params, :first_name, :last_name, :email, :language, :document_language).merge({
        language:          current_organization.language,
        document_language: current_organization.document_language
    })
    account = Account.lookup(account_attributes[:email]) || Account.create(account_attributes)
    return json(account) unless account.valid?

    # Find role for account in organization if it exists.
    membership_attributes = pick(params, :role, :concealed)
    return bad_request(error: 'Role is required') unless Account::ROLES.include? membership_attributes[:role]

    membership = current_organization.role_of(account)
    # Create a membership if account has no existing role
    if membership.nil?
      membership_attributes[:default] = true unless account.memberships.exists?
      membership = current_organization.memberships.create(membership_attributes.merge(account_id: account.id))
    elsif membership.role == Account::REVIEWER # or if account is a reviewer in this organization
      account.upgrade_reviewer_to_real(current_organization, membership_attributes[:role])
    elsif membership.role == Account::DISABLED
      return bad_request(error: 'That email address belongs to an inactive account.')
    else
      return conflict(error: 'That email address is already part of this organization.')
    end

    if account.pending?
      account.send_login_instructions(current_organization, current_account)
    else
      LifecycleMailer.membership_notification(account, current_organization, current_account).deliver_now
    end
    json account.canonical(membership: membership)
  end

  # Journalists are authorized to update any account in the organization.
  # Think about what the desired level of access control is.
  def update
    account = current_organization.accounts.find(params[:id])
    return forbidden unless account && current_account.allowed_to_edit_account?(account, current_organization)
    return json(account) unless account.update_attributes pick(params, :first_name, :last_name, :email,:language, :document_language)

    role = pick(params, :role)
    #account.update_attributes(role) if !role.empty? && current_account.admin?
    membership = current_organization.role_of(account)
    membership.update_attributes(role) if !role.empty? && current_account.admin?
    password = pick(params, :password)[:password]
    if (current_account.id == account.id) && password
      account.update(password: password)
    end
    json account.canonical(membership: membership)
  end

  # Resend a welcome email for a pending account.
  def resend_welcome
    return forbidden unless current_account.admin?

    account = current_organization.accounts.find(params[:id])
    LifecycleMailer.login_instructions(account, current_organization, current_account).deliver_now
    json nil
  end
  
  def mailboxes
    # TODO: Filter by status, once that exists
    @mailboxes = UploadMailbox.where(membership_id: current_account.memberships.pluck(:id))
    set_minimal_nav text:    'Back to the workspace',
                    xs_text: 'Workspace',
                    link:    '/search/'
  end
  
  def create_mailbox
    @mailbox = UploadMailbox.create(membership: current_account.memberships.default.first, sender: params[:email])
    if @mailbox.valid?
      flash[:success] = 'You’ve created a new upload mailbox!'
    else
      flash[:error] = 'Sorry, something went wrong creating that mailbox.'
    end
    redirect_to :mailboxes
  end
  
  def revoke_mailbox
    @mailbox = UploadMailbox.find(params[:id])
    return forbidden unless @mailbox.membership.account == current_account

    # TODO: Replace destroy with status update
    if @mailbox.destroy
      flash[:success] = 'You’ve successfully revoked that mailbox.'
    else
      flash[:error] = 'Sorry, something went wrong revoking that mailbox.'
    end
    redirect_to :mailboxes
  end

  # Removing an account only changes their role so that they cannot
  # login. Ther documents, projects, and name remain.
  def destroy
    return forbidden unless current_account.admin?

    current_organization.memberships.where(account_id: params[:id]).update_all(role: Account::DISABLED)
    json nil
  end

end
