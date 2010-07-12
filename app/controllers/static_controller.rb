class StaticController < ApplicationController

  before_filter :bouncer if Rails.env.staging?
  HELP_PAGES = AjaxHelpController::PAGES.map {|page| page.to_s }
  HELP_PAGE_TITLES = AjaxHelpController::PAGE_TITLES
  
  def home
    @posts = date_sorted(yaml_for('home'))
  end

  def about
  end

  def contact
  end

  def contributors
    yaml          = yaml_for('contributors')
    @partners     = yaml['partners']
    @contributors = yaml['contributors']
  end

  def opensource
    yaml    = yaml_for('opensource')
    @news   = yaml['news']
    @github = yaml['github']
  end

  def faq
  end

  def terms
  end

  def privacy
  end

  def featured
  end

  def news
    @news = date_sorted(yaml_for('news'))
  end
  
  def help
    page = HELP_PAGES.include?(params[:page]) ? params[:page] : 'index'
    
    contents = File.read("#{Rails.root}/app/views/help/#{page}.markdown")
    links_filename = "#{Rails.root}/app/views/help/#{page}_links.markdown"
    links = File.exists?(links_filename) ? File.read(links_filename) : ""
    @help_content = RDiscount.new(contents+links).to_html.gsub /\[([^\]]*?)\]\[\]/i, '\1'
    @help_pages = HELP_PAGES
    @help_page_titles = HELP_PAGE_TITLES
    @page = page
  end

  private

  def date_sorted(list)
    list.sort_by {|item| item.last }.reverse
  end

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/static/#{action}.yml")
  end

end
