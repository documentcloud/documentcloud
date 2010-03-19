class AdminController < ApplicationController
  layout 'workspace'

  before_filter :admin_required

  # The Admin Dashboard
  def index
    @documents_by_access  = DC::Statistics.documents_by_access.to_json
    @average_entity_count = DC::Statistics.average_entity_count.to_json
    @average_page_count   = DC::Statistics.average_page_count.to_json
    @daily_documents      = DC::Statistics.daily_documents.to_json
    @daily_pages          = DC::Statistics.daily_pages.to_json
    @total_pages          = DC::Statistics.total_pages.to_json
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
    acc.send_login_instructions
    @success = "Account Created. Welcome email sent to #{acc.email}."
  end

  # Login as a given account, without needing a password.
  def login_as
    acc = Account.find_by_email(params[:email])
    return not_found unless acc
    acc.authenticate(session)
    redirect_to '/'
  end

  # Render the TODO.txt out as a web page.
  def todo
    @todo_text = File.read("#{Rails.root}/TODO")
    @todo_text.gsub!(/^(\w+[^\n]+:)/, '</ul><h2>\1</h2><ul>').gsub!(/^\s+\*(.+?)\n\s*\n/m, '<li>\1</li>')
    render :action => 'todo', :layout => nil
  end

  def test_exception_notifier
    1 / 0
  end

  def test_embedded_viewer
    render :layout => nil
  end


  private

  def fail(message)
    @failure = message
  end

end