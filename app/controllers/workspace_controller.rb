class WorkspaceController < ApplicationController
  
  before_filter :bouncer unless Rails.development?
    
  def index
    @account = current_account
  end
  
  def signup
    return render unless request.post?
    org = Organization.create(params[:organization])
    account = Account.create(params[:account].merge({:organization => org}))
    if org.errors.any? || account.errors.any?
      @failed_signup = org.errors.full_messages + account.errors.full_messages
    else
      account.authenticate_session(session)
      redirect_to '/workspace'
    end
  end
  
  def login
    return render unless request.post?
    account = Account.log_in(params[:email], params[:password], session)
    account ? redirect_to('/workspace') : @failed_login = true
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
  
end