class WorkspaceController < ApplicationController
  
  RESULTS_REQUEST = /\A\/results/
  
  before_filter :bouncer unless Rails.development?
    
  def index    
    redirect_to '/search' unless current_account || results_request?
  end
  
  def signup
    return render unless request.post?
    org = Organization.create(params[:organization])
    return fail(org.errors.full_messages.first) if org.errors.any?
    acc = Account.create(params[:account].merge({:organization => org}))
    return org.destroy && fail(acc.errors.full_messages.first) if acc.errors.any?
    acc.authenticate(session)
    redirect_to '/'
  end
  
  def login
    return render unless request.post?
    account = Account.log_in(params[:email], params[:password], session)
    account ? redirect_to('/') : fail(true)
  end
  
  def logout
    reset_session
    redirect_to '/'
  end
  
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