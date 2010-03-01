class WorkspaceController < ApplicationController

  RESULTS_REQUEST = /\A\/results/

  before_filter :bouncer, :only => :signup  unless Rails.env.development?
  before_filter :bouncer, :except => :index if Rails.env.staging?

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index
    if current_organization && current_account
      @projects         = current_account.projects.all(:include => ['project_memberships'])
      @processing_jobs  = current_account.processing_jobs.all
      @document_count   = Document.owned_by(current_account).count
      @annotation_count = Annotation.owned_by(current_account).count
      return
    end
    return redirect_to('/home') unless request.headers['Authorization']
    render :action => 'home', :layout => 'empty'
  end

  def home
    render :action => 'home', :layout => 'empty'
  end

  # Attempt a new signup for DocumentCloud -- includes both the organization and
  # its first account. If everthing's kosher, the journalist is logged in.
  # NB: This needs to stay access controlled by the bouncer throughout the beta.
  def signup
    return render unless request.post?
    org = Organization.create(params[:organization])
    return fail(org.errors.full_messages.first) if org.errors.any?
    acc = Account.create(params[:account].merge({:organization => org, :role => Account::ADMINISTRATOR}))
    return org.destroy && fail(acc.errors.full_messages.first) if acc.errors.any?
    acc.authenticate(session)
    redirect_to '/'
  end

  # Display the signup information page.
  def signup_info
  end

  # /login handles both the login form and the login request.
  def login
    return render unless request.post?
    account = Account.log_in(params[:email], params[:password], session)
    account ? redirect_to('/') : fail(true)
  end

  # Logging out clears your entire session.
  def logout
    reset_session
    redirect_to '/'
  end

  # Render the TODO.txt file out in public.
  # TODO: (ha!) remove when no longer appropriate.
  def todo
    @todo_text = File.read("#{Rails.root}/TODO")
    @todo_text.gsub!(/^(\w+[^\n]+:)/, '</ul><h2>\1</h2><ul>').gsub!(/^\s+\*(.+?)\n\s*\n/m, '<li>\1</li>')
    render :action => 'todo', :layout => false
  end


  private

  def fail(message)
    @failure = message
  end

  def results_request?
    !!request.path.match(RESULTS_REQUEST)
  end

end