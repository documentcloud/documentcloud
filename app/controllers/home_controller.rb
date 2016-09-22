class HomeController < ApplicationController
  include DC::Access

  # Regex that matches missed markdown links in `[title][]` format.
  MARKDOWN_LINK_REPLACER = /\[([^\]]*?)\]\[\]/i

  before_action :secure_only
  before_action :current_account
  before_action :bouncer if exclusive_access?

  def index
    @canonical_url = homepage_url
    redirect_to search_url if logged_in? and env["PATH_INFO"].slice(0,5) != "/home"
    @document = Rails.cache.fetch( "homepage/featured_document" ) do
      time = Rails.env.production? ? 2.weeks.ago : nil
      Document.unrestricted.published.popular.random.since(time).first
    end
  end

  def opensource
    yaml    = yaml_for('opensource')
    @news   = yaml['news']
    @github = yaml['github']
  end

  def contributors
    yaml          = yaml_for('contributors')
    @partners     = yaml['partners']
    @contributors = yaml['contributors']
  end

  def terms
    # We launched with versions `1`/`2`, but converted to `1.0`/`2.0` same day.
    # Still need to support any incoming requests for `/terms/2` for a while.
    return redirect_to terms_path(version: "#{params[:version]}.0") if %w[1 2].include? params[:version]

    prepare_term_versions(changelog: 'terms/changelog')
    return not_found unless @version_numbers.include? @version

    @canonical_url = terms_url if @version == @current_terms['version']
    render layout: 'minimal', template: "home/terms/show"
  end

  def api_terms
    prepare_term_versions(changelog: 'api_terms/changelog')
    return not_found unless @version_numbers.include? @version

    @canonical_url = api_terms_url if @version == @current_terms['version']
    render layout: 'minimal', template: "home/api_terms/show"
  end

  def privacy
    render layout: 'minimal'
  end

  def faq
    render layout: 'minimal'
  end

  private

  def date_sorted(list)
    list.sort{|a,b| b.last <=> a.last }
  end

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/home/#{action}.yml")
  end

  def prepare_term_versions(changelog:)
    @versions = yaml_for(changelog).sort { |a, b| b['version'] <=> a['version'] }

    today           = Date.today
    @version_numbers = []
    @versions.map! do |v|
      v['version'] = v['version'].to_s
      v['start']   = Date.parse(v['start']) rescue nil
      v['end']     = Date.parse(v['end'])   rescue nil
      v['old']     = !v['current'] && (!v['start'] || v['start'] < today)
      v['pending'] = !v['current'] && v['start'] && today < v['start']
      @version_numbers.push v['version']
      v
    end

    @current_terms  = @versions.find { |v| v['current'] }
    @version = (params[:version] || @current_terms['version'])
    @viewing_terms = @versions.find { |v| v['version'] == @version }
  end

end
