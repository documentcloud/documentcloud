class WorkspaceController < ApplicationController
  
  RESULTS_REQUEST = /\A\/results/
  
  before_filter :bouncer unless Rails.development?
  
  # Main documentcloud.org page. Renders the workspace if logged in or 
  # searching, the home page otherwise.
  def index
    return if current_account || results_request?
    render :template => 'search/search', :layout => 'empty'
  end
  
  # Attempt a new signup for DocumentCloud -- includes both the organization and
  # its first account. If everthing's kosher, the journalist is logged in.
  def signup
    return render unless request.post?
    org = Organization.create(params[:organization])
    return fail(org.errors.full_messages.first) if org.errors.any?
    acc = Account.create(params[:account].merge({:organization => org}))
    return org.destroy && fail(acc.errors.full_messages.first) if acc.errors.any?
    acc.authenticate(session)
    redirect_to '/'
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
    @todo_text = File.read("#{RAILS_ROOT}/TODO")
    @todo_text.gsub!(/^([A-Z]+:)/, '</ul><h2>\1</h2><ul>').gsub!(/\*(.+?)\n\s*\n/m, '<li>\1</li>')
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