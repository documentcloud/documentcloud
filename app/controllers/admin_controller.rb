class AdminController < ApplicationController
  layout nil

  before_filter :admin_required

  # Attempt a new signup for DocumentCloud -- includes both the organization and
  # its first account. If everthing's kosher, the journalist is logged in.
  # NB: This needs to stay access controlled by the bouncer throughout the beta.
  def signup
    return render(:layout => 'workspace') unless request.post?
    org = Organization.create(params[:organization])
    return fail(org.errors.full_messages.first) if org.errors.any?
    acc = Account.create(params[:account].merge({:organization => org, :role => Account::ADMINISTRATOR}))
    return org.destroy && fail(acc.errors.full_messages.first) if acc.errors.any?
    acc.send_login_instructions
    render :text => "Account Created. Welcome email sent to #{acc.email}"
    # acc.authenticate(session)
    # redirect_to '/'
  end

  def test_exception_notifier
    1 / 0
  end

  def test_embedded_viewer

  end


  private

  def fail(message)
    @failure = message
  end

end