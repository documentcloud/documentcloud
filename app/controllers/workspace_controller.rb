class WorkspaceController < ApplicationController

  HELP_PAGES  = AjaxHelpController::PAGES.map {|page| page.to_s }
  HELP_TITLES = AjaxHelpController::PAGE_TITLES

  # Regex that matches missed markdown links in `[title][]` format.
  MARKDOWN_LINK_REPLACER = /\[([^\]]*?)\]\[\]/i

  before_action :bouncer, :except => :index if exclusive_access?

  before_action :secure_only

  # Main documentcloud.org page. Renders the workspace if logged in or
  # searching, the home page otherwise.
  def index
    if logged_in? and current_account.real?
      @projects = Project.load_for(current_account) # TODO: Filter out invitations
      @project_invitations = [] # TODO: Fill this is in with invitations
      @current_organization = current_account.organization
      @organizations = Organization.all_slugs
      @has_documents = Document.owned_by(current_account).exists?
      return render :template => 'workspace/index'
    end
    redirect_to public_search_url(query: params[:query])
  end

  # Render a help page as regular HTML, including correctly re-directed links.
  def help
    @page           = HELP_PAGES.include?(params[:page]) ? params[:page] : 'index'
    contents        = File.read("#{Rails.root}/app/views/help/eng/#{@page}.markdown")
    links_filename  = "#{Rails.root}/app/views/help/eng/#{@page}_links.markdown"
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
    render :layout => nil
  end

end
