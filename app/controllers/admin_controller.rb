class AdminController < ApplicationController
  layout 'workspace'

  before_filter :admin_required, :except => [:save_analytics]

  # The Admin Dashboard
  def index
    @documents_by_access           = DC::Statistics.documents_by_access.to_json
    @pages_per_minute              = DC::Statistics.pages_per_minute.to_json
    @average_page_count            = DC::Statistics.average_page_count.to_json
    @total_pages                   = DC::Statistics.total_pages.to_json
    @daily_documents               = keys_to_timestamps(DC::Statistics.daily_documents(2.weeks.ago)).to_json
    @daily_pages                   = keys_to_timestamps(DC::Statistics.daily_pages(2.weeks.ago)).to_json
    @public_per_account            = DC::Statistics.public_documents_per_account.to_json
    @private_per_account           = DC::Statistics.private_documents_per_account.to_json
    @pages_per_account             = DC::Statistics.pages_per_account.to_json
    @documents                     = Document.finished.chronological.all(:limit => 5).map {|d| d.admin_attributes }.to_json
    @failed_documents              = Document.failed.chronological.all(:limit => 3).map {|d| d.admin_attributes }.to_json
    @accounts                      = Account.all.to_json
    @organizations                 = Organization.all.to_json
    @instances                     = DC::AWS.new.describe_instances.to_json
    @top_documents                 = RemoteUrl.top_documents(7, :limit => 5).to_json
    @remote_url_hits_last_week     = DC::Statistics.remote_url_hits_last_week.to_json
    @remote_url_hits_last_year     = DC::Statistics.remote_url_hits_last_year.to_json
    @count_organizations_embedding = DC::Statistics.count_organizations_embedding.to_json
    @count_total_collaborators     = DC::Statistics.count_total_collaborators.to_json


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

  # Endpoint for our pixel-ping application, to save our analytic data every
  # so often.
  def save_analytics
    return forbidden unless params[:secret] == SECRETS['pixel_ping']
    data = JSON.parse(params[:json])
    data.each do |key, hits|
      doc_id, url = *key.split(':', 2)
      RemoteUrl.record_hits(doc_id.to_i, url, hits)
    end
    json nil
  end

  # Spin up a new CloudCrowd medium worker, for processing. It takes a while
  # to start the worker, so we let it run in a separate thread and return.
  def launch_worker
    return bad_request unless request.post?
    Thread.new do
      DC::AWS.new.boot_instance({
        :type => 'c1.medium',
        :scripts => [DC::AWS::SCRIPTS[:update], DC::AWS::SCRIPTS[:node]]
      })
    end
    json nil
  end

  def vacuum_analyze
    DC::Store::BackgroundJobs.vacuum_analyze
    json nil
  end

  def force_backup
    DC::Store::BackgroundJobs.backup_database
    json nil
  end

  # Terminate an EC2 instance.
  def terminate_instance
    return bad_request unless request.post? && params[:instance]
    DC::AWS.new.terminate_instance(params[:instance])
    json nil
  end

  def reprocess_failed_document
    Document.failed.last.queue_import
    json nil
  end

  # Login as a given account, without needing a password.
  def login_as
    acc = Account.lookup(params[:email])
    return not_found unless acc
    acc.authenticate(session)
    redirect_to '/'
  end

  # Render the TODO.txt out as a web page.
  def todo
    @todo_text = File.read("#{Rails.root}/TODO")
    @todo_text.gsub!(/^(\w+[^\n]+:)/, '</ul><h2>\1</h2><ul>').gsub!(/^\s+\*(.+?)\n\s*\n/m, '<li>\1</li>')
    render :layout => false
  end

  def test_exception_notifier
    1 / 0
  end

  def test_embedded_viewer
    render :layout => false
  end

  def test_s3_viewer
    render :layout => false
  end


  private

  def fail(message)
    @failure = message
  end

  # Pass in the seconds since the epoch, for JavaScript.
  def keys_to_timestamps(hash)
    result = {}
    hash.each do |key, value|
      time = Date.parse(key).to_time
      utc  = (time + time.utc_offset).utc
      result[utc.to_f.to_i] = value
    end
    result
  end

end