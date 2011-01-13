class AdminController < ApplicationController

  before_filter :admin_required, :except => [:save_analytics, :queue_length]

  # The Admin Dashboard
  def index
    @documents_by_access           = DC::Statistics.documents_by_access.to_json
    @average_page_count            = DC::Statistics.average_page_count.to_json
    @embedded_documents            = DC::Statistics.embedded_document_count.to_json
    @total_pages                   = DC::Statistics.total_pages.to_json
    @daily_documents               = keys_to_timestamps(DC::Statistics.daily_documents).to_json
    @daily_pages                   = keys_to_timestamps(DC::Statistics.daily_pages).to_json
    @weekly_documents              = keys_to_timestamps(DC::Statistics.weekly_documents).to_json
    @weekly_pages                  = keys_to_timestamps(DC::Statistics.weekly_pages).to_json
    @documents                     = Document.finished.chronological.all(:limit => 5).map {|d| d.admin_attributes }.to_json
    @failed_documents              = Document.failed.chronological.all(:limit => 3).map {|d| d.admin_attributes }.to_json
    @organizations                 = Organization.all.to_json
    @instances                     = DC::AWS.new.describe_instances.to_json
    @top_documents                 = RemoteUrl.top_documents(7, :limit => 5).to_json
    @remote_url_hits_last_week     = DC::Statistics.remote_url_hits_last_week.to_json
    @remote_url_hits_last_year     = DC::Statistics.remote_url_hits_last_year.to_json
    @count_organizations_embedding = DC::Statistics.count_organizations_embedding.to_json
    @count_total_collaborators     = DC::Statistics.count_total_collaborators.to_json
    @numbers                       = DC::Statistics.by_the_numbers.to_json
    @accounts                      = [].to_json
    if params[:accounts]
      @accounts                    = Account.all.to_json
      @public_per_account          = DC::Statistics.public_documents_per_account.to_json
      @private_per_account         = DC::Statistics.private_documents_per_account.to_json
      @pages_per_account           = DC::Statistics.pages_per_account.to_json
    end
  end

  def hits_on_documents
    json RemoteUrl.top_documents(365, :limit => 1000).to_json
  end

  def all_accounts
    json({
      'public_per_account'  => DC::Statistics.public_documents_per_account,
      'private_per_account' => DC::Statistics.private_documents_per_account,
      'pages_per_account'   => DC::Statistics.pages_per_account,
      'accounts'            => Account.all
    })
  end

  def top_documents_csv
    return not_found unless request.format.csv?
    csv = DC::Statistics.top_documents_csv
    send_data csv, :type => :csv, :filename => 'documents.csv'
  end

  def accounts_csv
    return not_found unless request.format.csv?
    csv = DC::Statistics.accounts_csv
    send_data csv, :type => :csv, :filename => 'documents.csv'
  end

  # Attempt a new signup for DocumentCloud -- includes both the organization and
  # its first account. If everything's kosher, the journalist is logged in.
  # NB: This needs to stay access controlled by the bouncer throughout the beta.
  def signup
    unless request.post?
      @params = {:organization => {}, :account => {}}
    end
    return render unless request.post?
    @params = params
    org = Organization.create(params[:organization])
    return fail(org.errors.full_messages.first) if org.errors.any?
    params[:account][:email].strip! if params[:account][:email]
    acc = Account.create(params[:account].merge({:organization => org, :role => Account::ADMINISTRATOR}))
    return org.destroy && fail(acc.errors.full_messages.first) if acc.errors.any?
    acc.send_login_instructions
    @success = "Account Created. Welcome email sent to #{acc.email}."
    @params = {:organization => {}, :account => {}}
  end

  # Endpoint for our pixel-ping application, to save our analytic data every
  # so often -- delegate to a cloudcrowd job.
  def save_analytics
    return forbidden unless params[:secret] == SECRETS['pixel_ping']
    RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      :action => 'save_analytics', :inputs => [params[:json]]
    }.to_json})
    json nil
  end

  # Ensure that the length of the pending document queue is ok.
  def queue_length
    ok = Document.pending.count <= Document::WARN_QUEUE_LENGTH
    render :text => ok ? 'OK' : 'OVERLOADED'
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

  def optimize_solr
    RestClient.get Sunspot.config.solr.url + '/update?optimize=true&waitFlush=false'
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
    doc = Document.failed.last
    doc.queue_import DC::Access::PRIVATE
    json nil
  end

  # Login as a given account, without needing a password.
  def login_as
    acc = Account.lookup(params[:email])
    return not_found unless acc
    acc.authenticate(session)
    redirect_to '/'
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

  def test_multi_viewer
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