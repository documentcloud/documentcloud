require 'dc/aws'

class AdminController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:save_analytics, :queue_length]

  before_action :secure_only,    :only   => [:index, :signup, :login_as]
  before_action :admin_required, :except => [:save_analytics, :queue_length, :test_embedded_search, :test_embedded_note, :test_embedded_page, :test_embedded_viewer, :health_check]
  
  READONLY_ACTIONS = [
    :index, :expire_stats, :hits_on_documents, :all_accounts, :top_documents_csv, :accounts_csv,
    :charge, :download_document_hits, :organization_statistics, :account_statistics, :queue_length,
    :launch_worker, :terminate_instance, :login_as, :test_exception_notifier, :test_embedded_viewer,
    :test_embedded_page, :test_embedded_note, :test_embedded_search, :health_check
  ]
  before_action :read_only_error, :except => READONLY_ACTIONS if read_only?

  # The Admin Dashboard
  def index
    respond_to do |format|
      format.json do
        @response = {
          :stats => {
            :documents_by_access           => DC::Statistics.documents_by_access,
            :embedded_documents            => DC::Statistics.embedded_document_count,
            :average_page_count            => DC::Statistics.average_page_count,
            :daily_documents               => keys_to_timestamps(DC::Statistics.daily_documents(1.month.ago)),
            :daily_pages                   => keys_to_timestamps(DC::Statistics.daily_pages(1.month.ago)),
            :weekly_documents              => keys_to_timestamps(DC::Statistics.weekly_documents),
            :weekly_pages                  => keys_to_timestamps(DC::Statistics.weekly_pages),
            :daily_hits_on_documents       => keys_to_timestamps(DC::Statistics.daily_hits_on_documents(1.month.ago)),
            :weekly_hits_on_documents      => keys_to_timestamps(DC::Statistics.weekly_hits_on_documents),
            :daily_hits_on_notes           => keys_to_timestamps(DC::Statistics.daily_hits_on_notes(1.month.ago)),
            :weekly_hits_on_notes          => keys_to_timestamps(DC::Statistics.weekly_hits_on_notes),
            :daily_hits_on_searches        => keys_to_timestamps(DC::Statistics.daily_hits_on_searches(1.month.ago)),
            :weekly_hits_on_searches       => keys_to_timestamps(DC::Statistics.weekly_hits_on_searches),
            :total_pages                   => DC::Statistics.total_pages,

            :instances                     => DC::AWS.new.describe_instances,
            :remote_url_hits_last_week     => DC::Statistics.remote_url_hits_last_week,
            :remote_url_hits_all_time      => DC::Statistics.remote_url_hits_all_time,
            :count_organizations_embedding => DC::Statistics.count_organizations_embedding,
            :count_total_collaborators     => DC::Statistics.count_total_collaborators,
            :numbers                       => DC::Statistics.by_the_numbers,
          },
          :documents        => Document.finished.chronological.limit(5).map {|d| d.admin_attributes },
          :failed_documents => Document.failed.chronological.limit(3).map {|d| d.admin_attributes },
          :top_documents    => RemoteUrl.top_documents(7, 5),
          :top_searches     => RemoteUrl.top_searches(7,  5),
          :top_notes        => RemoteUrl.top_notes(7, 5),
          :accounts         => [],
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
      
      format.html{ render }
    end
  end
  
  def expire_stats
    respond_to do |format|
      format.any do
        expire_page "/admin/index.json"
        redirect_to :action => :index
      end
    end
  end

  def hits_on_documents
    json RemoteUrl.top_documents(365).to_json
  end

  def all_accounts
    json({
      'public_per_account'  => DC::Statistics.public_documents_per_account,
      'private_per_account' => DC::Statistics.private_documents_per_account,
      'pages_per_account'   => DC::Statistics.pages_per_account,
      'accounts'            => Account.all.map {|a| a.canonical(:include_organization => true) }
    })
  end

  def top_documents_csv
    return not_found unless request.format.csv?
    csv = DC::Statistics.top_documents_csv
    send_data csv, :type => :csv, :filename => 'documents.csv'
  end

  def accounts_csv
    return not_found unless request.format.csv?
    deliver_csv("#{Date.today}-accounts") do | csv |
      DC::Statistics.accounts_csv(csv)
    end
  end

  # Attempt a new signup for DocumentCloud -- includes both the organization and
  # its first account. If everything's kosher, the journalist is logged in.
  # NB: This needs to stay access controlled by the bouncer throughout the beta.
  DEFAULT_SIGNUP_PARAMS = {
    :account => {},
    :organization => { :language=>DC::Language::DEFAULT,:document_language=>DC::Language::DEFAULT }
  }
  def signup
    unless request.post?
      @params = DEFAULT_SIGNUP_PARAMS.dup.merge(pick(params, :organization, :account))
      return render
    end
    @params = params

    user_params = params.require(:account).permit(:first_name,:last_name,:email,:slug,:language,:document_language)

    # First see if an account already exists for the email
    @account = Account.lookup(user_params[:email])
    if @account # Check if the account should be moved
      if "t" != params[:move_account]
        fail( "#{user_params[:email]} already exists!" ) and return
      end
    else
      @account = Account.create( user_params
        .merge( :language=>DC::Language::DEFAULT, :document_language=>DC::Language::DEFAULT ) )
      if @account.errors.any?
        fail( @account.errors.full_messages.join(', ') ) and return
      end
    end

    # create the organization
    organization_params = params.require(:organization).permit(:name,:slug,:language,:document_language)
    organization = Organization.create( organization_params )
    return fail(organization.errors.full_messages.join(', ')) if organization.errors.any?

    # link the account to the organization
    membership = @account.memberships.create({
        :role => Account::ADMINISTRATOR, :default => true, :organization=>organization
    })
    @account.set_default_membership(membership)

    @account.send_login_instructions
    @success = "Account Created. Welcome email sent to #{@account.email}."
    # clear variables so the form displays fresh
    @account = nil
    @params  = DEFAULT_SIGNUP_PARAMS.dup
  end

  def download_document_hits
    organization=Organization.find_by_slug(params[:slug])
    if !organization
      flash[:error]="Organization for #{params[:slug]} was not found"
      render :action=>:document_hits and return
    end
    deliver_csv("#{organization.slug}-hits") do |csv|
      csv << [ "Day","Hits","Document" ]
      urls=RemoteUrl
        .where(:document_id=>organization.documents.published.ids)
        .group(:date_recorded,:document_id)
        .select('date_recorded','document_id','sum(hits) as hits')
      urls.each do | hit |
        csv << [ hit.date_recorded.strftime("%Y-%m-%d"), hit.hits, hit.document.canonical_url(:html) ]
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
      format.html{ render }
      format.any{ redirect_to :format => :html, :params => pick(params, :id, :slug) }
    end
  end
  
  def account_statistics
    account = case
    when params[:email]
      Account.lookup(params[:email])
    when
      Account.find(params[:id])
    end
    return not_found unless account
    respond_to do |format|
      format.json do
        @response = Document.upload_statistics(:account, account.id)
        render_cross_origin_json
      end
      format.html{ render }
      format.any{ redirect_to :format => :html, :params => pick(params, :id, :slug) }
    end
  end

  def manage_organization
    query = if params[:slug]
              ["lower(slug)=:slug or lower(name)=:slug",{:slug=>params[:slug].downcase}]
            elsif params[:id]
              {:id=>params[:id]}
            end
    @organization = Organization.where(query).includes(:memberships=>:account).first
    if @organization.nil?
      flash[:error] = "Organization for '#{params[:slug]}' was not found"
      render :action=>:organizations
    end
  end

  def update_organization
    @organization = Organization.find(params[:id])
    if @organization.update_attributes( {demo: false}.merge(pick(params,:name,:slug,:demo)) )
      redirect_to :action=>'organizations' and return
    end
    flash[:error] = @organization.errors.full_messages.join("; ")
    render :action=>:manage_organization
  end

  def update_memberships
    @account = Account.find(params[:id])
    @account.set_default_membership(@account.memberships.find(params[:default_membership]))
    params[:role].each do | membership_id, role|
      @account.memberships.find(membership_id).update_attributes({ role: role })
    end
    redirect_to :action=>'memberships'
  end

  def manage_memberships
    @account = if params[:email]
                 Account.lookup(params[:email])
               elsif params[:id]
                 Account.find(params[:id])
               end
    if !@account
      flash[:error]="Account for #{params[:email]} was not found"
      render :action=>:memberships and return
    end
  end

  # Endpoint for our pixel-ping application, to save our analytic data every
  # so often -- delegate to a cloudcrowd job.
  def save_analytics
    return forbidden unless params[:secret] == DC::SECRETS['pixel_ping']
    RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      :action => 'save_analytics', :inputs => [params[:json]]
    }.to_json})
    json nil
  end

  # Ensure that the length of the pending document queue is ok.
  def queue_length
    ok = Document.pending.count <= Document::WARN_QUEUE_LENGTH
    render :plain => ok ? 'OK' : 'OVERLOADED'
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
    doc.queue_import :access => DC::Access::PRIVATE
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
    render :layout => nil
  end

  def test_embedded_page
    render :layout => nil
  end

  def test_embedded_note
    render :layout => nil
  end

  def test_embedded_search
    render :layout => nil
  end

  def health_check
    render :template => "admin/health_check/#{params[:subject]}_#{params[:env]}", :layout => nil
  end

  private

  def fail(message)
    @failure = message
    flash[:error] = message
  end

  # Pass in the seconds since the epoch, for JavaScript.
  def keys_to_timestamps(hash)
    result = {}
    strings = hash.keys.first.is_a? String
    hash.each do |key, value|
      time = (strings ? Date.parse(key) : key ).to_time
      utc  = (time + time.utc_offset).utc
      result[utc.to_f.to_i] = value
    end
    result
  end

  # Streams a CSV download to the browser
  def deliver_csv( filename )
    response.headers["Content-Type"] ||= 'text/csv'
    response.headers["Content-Disposition"] = "attachment; filename=#{filename}.csv"
    response.headers['Last-Modified'] = Time.now.ctime.to_s
    self.response_body = Enumerator.new do |stream|
      csv = CSV.new(stream)
      yield csv
    end
  end

end
