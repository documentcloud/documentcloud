class HomeController < ApplicationController
  include DC::Access

  # Regex that matches missed markdown links in `[title][]` format.
  MARKDOWN_LINK_REPLACER = /\[([^\]]*?)\]\[\]/i

  before_action :prefer_secure
  before_action :current_account
  before_action :bouncer if Rails.env.staging?

  def index
    time = Rails.env.production? ? 2.weeks.ago : nil
    @document = Document.unrestricted.published.popular.random.since(time).first
  end

  def opensource
    yaml    = yaml_for('opensource')
    @news   = yaml['news']
    @github = yaml['github']
  end

  def news
    @news = date_sorted(yaml_for('news'))
  end

  def contributors
    yaml          = yaml_for('contributors')
    @partners     = yaml['partners']
    @contributors = yaml['contributors']
  end


  private

  def date_sorted(list)
    list.sort{|a,b| b.last <=> a.last }
  end

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/home/#{action}.yml")
  end

end
