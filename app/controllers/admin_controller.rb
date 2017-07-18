require 'dc/aws'

class AdminController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:save_analytics, :queue_length]

  before_action :secure_only,    only:   [:index, :add_organization, :login_as]
  before_action :admin_required, except: [:save_analytics, :queue_length, :test_embedded_search, :test_embedded_note, :test_embedded_page, :test_embedded_viewer, :health_check]
  
  READONLY_ACTIONS = [
    :index, :expire_stats, :hits_on_documents, :all_accounts, :top_documents_csv, :accounts_csv,
    :charge, :download_document_hits, :organization_statistics, :account_statistics, :queue_length,
    :launch_worker, :terminate_instance, :login_as, :test_exception_notifier, :test_embedded_viewer,
    :test_embedded_page, :test_embedded_note, :test_embedded_search, :health_check
  ]
  before_action :read_only_error, except: READONLY_ACTIONS if read_only?

  # The Admin Dashboard
  def index
    respond_to do |format|
      format.json do
        @response = {
          stats: {
            documents_by_access:           DC::Statistics.documents_by_access,
            embedded_documents:            DC::Statistics.embedded_document_count,
            average_page_count:            DC::Statistics.average_page_count,
            daily_documents:               keys_to_timestamps(DC::Statistics.daily_documents(1.month.ago)),
            daily_pages:                   keys_to_timestamps(DC::Statistics.daily_pages(1.month.ago)),
            weekly_documents:              keys_to_timestamps(DC::Statistics.weekly_documents),
            weekly_pages:                  keys_to_timestamps(DC::Statistics.weekly_pages),
            daily_hits_on_documents:       keys_to_timestamps(DC::Statistics.daily_hits_on_documents(1.month.ago)),
            weekly_hits_on_documents:      keys_to_timestamps(DC::Statistics.weekly_hits_on_documents),
            daily_hits_on_notes:           keys_to_timestamps(DC::Statistics.daily_hits_on_notes(1.month.ago)),
            weekly_hits_on_notes:          keys_to_timestamps(DC::Statistics.weekly_hits_on_notes),
            daily_hits_on_searches:        keys_to_timestamps(DC::Statistics.daily_hits_on_searches(1.month.ago)),
            weekly_hits_on_searches:       keys_to_timestamps(DC::Statistics.weekly_hits_on_searches),
            total_pages:                   DC::Statistics.total_pages,

            instances:                     DC::AWS.new.describe_instances,
            remote_url_hits_last_week:     DC::Statistics.remote_url_hits_last_week,
            remote_url_hits_all_time:      DC::Statistics.remote_url_hits_all_time,
            count_organizations_embedding: DC::Statistics.count_organizations_embedding,
            count_total_collaborators:     DC::Statistics.count_total_collaborators,
            numbers:                       DC::Statistics.by_the_numbers,
          },
          documents:        Document.finished.chronological.limit(5).map {|d| d.admin_attributes },
          failed_documents: Document.failed.chronological.limit(3).map {|d| d.admin_attributes },
          top_documents:    RemoteUrl.top_documents(7, 5),
          top_searches:     RemoteUrl.top_searches(7,  5),
          top_notes:        RemoteUrl.top_notes(7, 5),
          accounts:         [],
        }
        if params[:accounts]
          @response[:accounts]                    = Account.all
          @response[:stats][:public_per_account]  = DC::Statistics.public_documents_per_account
          @response[:stats][:private_per_account] = DC::Statistics.private_documents_per_account
          @response[:stats][:pages_per_account]   = DC::Statistics.pages_per_account
        end
        cache_page @response.to_json
        render_cross_origin_json
      end
      
      format.html do
        @data_cache_path = DC::Store::AssetStore.new.authorized_url('cache/admin/index.json')
        render
      end
    end
  end
  
  def tools
    render layout: 'new'
  end

  def expire_stats
    respond_to do |format|
      format.any do
        expire_page "/admin/index.json"
        redirect_to action: 'index'
      end
    end
  end

  def hits_on_documents
    json RemoteUrl.top_documents(365).to_json
  end

  def all_accounts
    json({
      public_per_account:  DC::Statistics.public_documents_per_account,
      private_per_account: DC::Statistics.private_documents_per_account,
      pages_per_account:   DC::Statistics.pages_per_account,
      accounts:            Account.all.map {|a| a.canonical(include_organization: true) }
    })
  end

  def top_documents_csv
    return not_found unless request.format.csv?
    csv = DC::Statistics.top_documents_csv
    send_data csv, type: 'csv', filename: 'documents.csv'
  end

  def accounts_csv
    return not_found unless request.format.csv?
    deliver_csv("#{Date.today}-accounts") do |csv|
      DC::Statistics.accounts_csv(csv)
    end
  end

  # Attempt a new signup for DocumentCloud -- includes both the organization and
  # its first account. If everything's kosher, the journalist is logged in.
  # NB: This needs to stay access controlled by the bouncer throughout the beta.
  DEFAULT_SIGNUP_PARAMS = HashWithIndifferentAccess.new({
    account: {
      language: DC::Language::DEFAULT,
      document_language: DC::Language::DEFAULT
    },
    organization: {
      language: DC::Language::DEFAULT,
      document_language: DC::Language::DEFAULT
    }
  })
  def add_organization
    @params                = DEFAULT_SIGNUP_PARAMS.dup
    @params[:organization] = @params[:organization].merge(params[:organization] || {})
    @params[:account]      = @params[:account].merge(params[:account] || {})
    return render layout: 'new' unless request.post?

    user_params = params.require(:account).permit(:first_name, :last_name, :email)

    # First see if an account already exists for the email
    is_new_account = false
    unless @account = Account.lookup(user_params[:email])
      @account = Account.create(user_params.merge(DEFAULT_SIGNUP_PARAMS[:account]))
      if @account.errors.any?
        flash.now[:error] = @account.errors.full_messages.join(', ')
        return render layout: 'new'
      end
      is_new_account = true
    end

    # create the organization
    organization_params = params.require(:organization).permit(:name, :slug, :language, :document_language)
    organization = Organization.create(organization_params)
    if organization.errors.any?
      flash.now[:error] = organization.errors.full_messages.join(', ')
      @account.destroy if is_new_account
      return render layout: 'new'
    end

    # link the account to the organization
    membership = @account.memberships.create({
      organization: organization,
      role: Account::ADMINISTRATOR
    })
    @account.set_default_membership(membership) if is_new_account || params[:authorize] == 'y'

    @account.send_login_instructions(organization)
    flash.now[:success] = "<b>#{organization.name}</b> created and welcome email sent to <b>#{@account.email}</b>."
    @account = nil
    @params  = DEFAULT_SIGNUP_PARAMS.dup
    render layout: 'new'
  end

  def download_document_hits
    organization = Organization.find_by_slug(params[:slug])
    if !organization
      flash[:error] = "Sorry, we weren't able to find that organization for some reason."
      redirect_to :back and return
    end
    deliver_csv("#{organization.slug}-hits") do |csv|
      csv << ["Day","Hits","Document"]
      urls = RemoteUrl
        .where(document_id: organization.documents.published.ids)
        .group(:date_recorded, :document_id)
        .select('date_recorded', 'document_id', 'sum(hits) as hits')
      urls.each do |hit|
        csv << [hit.date_recorded.strftime("%Y-%m-%d"), hit.hits, hit.document.canonical_url(:html)]
      end
    end
  end
  
  def organization_statistics
    org = case
    when params[:slug]
      Organization.find_by_slug(params[:slug])
    when params[:id]
      Organization.find(params[:id])
    end
    return not_found unless org
    
    respond_to do |format|
      format.json do
        @response = Document.upload_statistics(:organization, org.id)
        render_cross_origin_json
      end
      format.any  { return not_implemented }
    end
  end
  
  def account_statistics
    account = case
    when params[:email]
      Account.lookup(params[:email])
    when params[:id]
      Account.find(params[:id])
    end
    return not_found unless account

    respond_to do |format|
      format.json do
        @response = Document.upload_statistics(:account, account.id)
        render_cross_origin_json
      end
      format.any  { return not_implemented }
    end
  end
  
  def organizations
    @since = if params[:since]
      if results = params[:since].match(/\A(?<val>\d+)(?<unit>months|days)\z/)
        results[:val].to_i.send(results[:unit]).ago
      else
        begin 
          Date.parse(params[:since]) 
        rescue
          Organization.first.created_at
        end
      end
    else
      Organization.first.created_at
    end

    @data = Document.where("created_at > ?", @since).group(:organization_id).pluck("organization_id, count(id), sum(page_count), sum(hit_count), sum(file_size), max(created_at)").sort_by{ |row| -row[1] }
    @organizations = Organization.all
    render layout: 'new'
  end
  
  def organization
    @organization = Organization.where("lower(slug) = lower(?)", params[:slug]).first
    return not_found unless @organization
    @since = if params[:since]
      if results = params[:since].match(/\A(?<val>\d+)(?<unit>months|days)\z/)
        results[:val].to_i.send(results[:unit]).ago
      else
        begin 
          Date.parse(params[:since]) 
        rescue
          @organization.created_at
        end
      end
    else
      @organization.created_at
    end
    @memberships         = @organization.memberships.real.with_account.order('accounts.created_at desc')
    @member_count        = @memberships.count
    @admin_count         = @memberships.where(role:1).count
    @documents           = Document.where(organization_id: @organization.id).where("created_at > ?", @since)
    @document_count      = @documents.count
    @documents_by_access = @documents.group(:access).count
    @public_count        = @documents_by_access.fetch(DC::Access::PUBLIC, 0)
    @private_count       = @documents_by_access.fetch(DC::Access::PRIVATE, 0) + @documents_by_access.fetch(DC::Access::ORGANIZATION, 0)
    @hit_count           = @documents.sum(:hit_count)
    @top_count           = params.fetch(:top_count, 20)
    top_data = @documents.group(:account_id).count.sort_by{|k,v| -v}.first(@top_count).map do |arr|
      m = @memberships.where(account_id: arr.first).first
      fake_account = Struct.new(:full_name, :email, :slug)
      accountish = m.blank? ? fake_account.new("Deleted User", nil, nil) : m.account
      [accountish, arr.last]
    end
    @top_uploaders       = Hash[top_data]
    render layout: 'new'
  end
  
  def edit_organization
    @organization = Organization.where(slug: params[:slug].downcase).first
    return not_found unless @organization
    render layout: 'new'
  end

  def update_organization
    @organization = Organization.find(params[:id])
    return not_found unless @organization
    if @organization.update_attributes({demo: false}.merge(pick(params[:organization], :name, :slug, :demo)))
      flash[:success] = "Updated #{@organization.name}!"
    else
      flash[:error] = @organization.errors.full_messages.join("; ")
    end
    redirect_to action: 'edit_organization', slug: @organization.slug
  end

  def memberships
    render layout: 'new'
  end

  def manage_memberships
    @account = if params[:email]
                 Account.lookup(params[:email])
               elsif params[:id]
                 Account.find(params[:id])
               end
    if !@account
      flash[:error] = "Account for <b>#{params[:email]}</b> was not found"
      redirect_to action: 'memberships' and return
    end
  end

  def update_memberships
    @account = Account.find(params[:id])
    @account.set_default_membership(@account.memberships.find(params[:default_membership]))
    params[:role].each do |membership_id, role|
      @account.memberships.find(membership_id).update_attributes({ role: role })
    end
    redirect_to action: 'memberships'
  end

  # Endpoint for our pixel-ping application, to save our analytic data every
  # so often -- delegate to a cloudcrowd job.
  def save_analytics
    return forbidden unless params[:secret] == DC::SECRETS['pixel_ping']
    RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {job: {
      action: 'save_analytics', inputs: [params[:json]]
    }.to_json})
    json nil
  end

  # Ensure that the length of the pending document queue is ok.
  def queue_length
    ok = Document.pending.count <= Document::WARN_QUEUE_LENGTH
    render plain: ok ? 'OK' : 'OVERLOADED'
  end

  # Spin up a new CloudCrowd medium worker, for processing. It takes a while
  # to start the worker, so we let it run in a separate thread and return.
  def launch_worker
    return bad_request unless request.post?
    Thread.new do
      DC::AWS.new.boot_instance({
        type:    'c1.medium',
        scripts: [DC::AWS::SCRIPTS[:update], DC::AWS::SCRIPTS[:node]]
      })
    end
    json nil
  end

  def vacuum_analyze
    DC::Store::BackgroundJobs.vacuum_analyze
    json nil
  end

  def optimize_solr
    DC::Store::BackgroundJobs.optimize_solr
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
    doc.queue_import access: DC::Access::PRIVATE
    json nil
  end

  # Login as a given account, without needing a password.
  def login_as
    acc = Account.lookup(params[:email])
    return not_found unless acc
    acc.authenticate(session, cookies)
    redirect_to '/'
  end

  def test_exception_notifier
    1 / 0
  end

  def test_embedded_viewer
    render layout: nil
  end

  def test_embedded_page
    render layout: nil
  end

  def test_embedded_note
    render layout: nil
  end

  def test_embedded_search
    render layout: nil
  end

  def health_check
    render template: "admin/health_check/#{params[:subject]}_#{params[:env]}", layout: nil
  end

  private

  def fail(message)
    @failure      = message
    flash[:error] = message
  end

  # Pass in the seconds since the epoch, for JavaScript.
  def keys_to_timestamps(hash)
    result  = {}
    strings = hash.keys.first.is_a? String
    hash.each do |key, value|
      time = (strings ? Date.parse(key) : key ).to_time
      utc  = (time + time.utc_offset).utc
      result[utc.to_f.to_i] = value
    end
    result
  end

  # Streams a CSV download to the browser
  def deliver_csv(filename)
    response.headers["Content-Type"] ||= 'text/csv'
    response.headers["Content-Disposition"] = "attachment; filename=#{filename}.csv"
    response.headers['Last-Modified'] = Time.now.ctime.to_s
    self.response_body = Enumerator.new do |stream|
      csv = CSV.new(stream)
      yield csv
    end
  end

end
