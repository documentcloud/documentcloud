class WorkspaceController < ApplicationController

  HELP_PAGES  = AjaxHelpController::PAGES.map {|page| page.to_s }
  HELP_TITLES = AjaxHelpController::PAGE_TITLES

  # Regex that matches missed markdown links in `[title][]` format.
  MARKDOWN_LINK_REPLACER = /\[([^\]]*?)\]\[\]/i

  skip_before_filter :verify_authenticity_token, :only => [:login]

  before_filter :bouncer, :except => :index if Rails.env.staging?

  before_filter :prefer_secure,   :only => [:index]
  before_filter :secure_only,     :only => [:login]

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index

    if logged_in?
      if current_account.real?
        @projects = Project.load_for(current_account)
        @current_organization = current_account.organization
        @organizations = Organization.all_slugs
        @has_documents = Document.owned_by(current_account).count(:limit => 1) > 0
        return render :template => 'workspace/index'
      else
        return redirect_to '/public/search'
      end
    end
    redirect_to '/home'
  end

  # Render a help page as regular HTML, including correctly re-directed links.
  def help
    @page           = HELP_PAGES.include?(params[:page]) ? params[:page] : 'index'
    contents        = File.read("#{Rails.root}/app/views/help/#{@page}.markdown")
    links_filename  = "#{Rails.root}/app/views/help/links/#{@page}_links.markdown"
    links           = File.exists?(links_filename) ? File.read(links_filename) : ""
    @help_content   = RDiscount.new(contents+links).to_html.gsub MARKDOWN_LINK_REPLACER, '<tt>\1</tt>'
    @help_pages     = HELP_PAGES - ['tour']
    @help_titles    = HELP_TITLES
    if !logged_in? || current_account.reviewer?
      render :template => 'home/help', :layout => 'home'
    else
      return self.index
    end
  end

  # Page for unsupported browsers, to request an upgrade.
  def upgrade
    render :layout => false
  end

end

