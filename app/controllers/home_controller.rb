class HomeController < ApplicationController
  include DC::Access

  # Regex that matches missed markdown links in `[title][]` format.
  MARKDOWN_LINK_REPLACER = /\[([^\]]*?)\]\[\]/i

  before_action :secure_only
  before_action :current_account
  before_action :bouncer if exclusive_access?

  def index
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
    @versions = yaml_for('terms/changelog')['versions'].sort { |a, b| b['version'] <=> a['version'] }

    @current_terms  = @versions.find { |v| v['current'] }

    version = (params[:version] || @current_terms['version'])
    version_numbers = @versions.map { |v| v['version'] }
    return not_found unless version_numbers.include? version

    @canonical_url = terms_url if version == @current_terms['version']
    @viewing_terms = @versions.find { |v| v['version'] == version }

    render layout: 'minimal', template: "home/terms/show"
  end

  def api_terms
    @current_version = '1'
    @version = params[:version] || @current_version
    return not_found unless %w[1].include? @version

    @canonical_url = api_terms_url if @version == @current_version

    render layout: 'minimal', template: "home/api_terms/v#{@version}"
  end

  def privacy
    render layout: 'minimal'
  end

  private

  def date_sorted(list)
    list.sort{|a,b| b.last <=> a.last }
  end

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/home/#{action}.yml")
  end

end
