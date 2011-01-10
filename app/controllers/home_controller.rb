class HomeController < ApplicationController
  include DC::Access

  HELP_PAGES  = AjaxHelpController::PAGES.map {|page| page.to_s }
  HELP_TITLES = AjaxHelpController::PAGE_TITLES

  # Regex that matches missed markdown links in `[title][]` format.
  MARKDOWN_LINK_REPLACER = /\[([^\]]*?)\]\[\]/i

  def index
    @documents = Document.random(:conditions => {:access => PUBLIC}, :limit => 1)
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

  # Render a help page as regular HTML, including correctly re-directed links.
  def help
    @page           = HELP_PAGES.include?(params[:page]) ? params[:page] : 'index'
    contents        = File.read("#{Rails.root}/app/views/help/#{@page}.markdown")
    links_filename  = "#{Rails.root}/app/views/help/links/#{@page}_links.markdown"
    links           = File.exists?(links_filename) ? File.read(links_filename) : ""
    @help_content   = RDiscount.new(contents+links).to_html.gsub MARKDOWN_LINK_REPLACER, '<tt>\1</tt>'
    @help_pages     = HELP_PAGES
    @help_titles    = HELP_TITLES
  end


  private

  def date_sorted(list)
    list.sort_by {|item| item.last }.reverse
  end

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/static/#{action}.yml")
  end

end