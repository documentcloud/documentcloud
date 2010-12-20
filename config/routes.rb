ActionController::Routing::Routes.draw do |map|

  # Internal Search API.
  # /search/documents.json

  # Journalist workspace and surrounding HTML.
  map.with_options :controller => 'workspace' do |main|
    main.root
    main.home       '/future_home', :action => 'home' # re-enable this route after launch, until then, it's static/home
    main.results    '/results',     :action => 'index'
    main.signup     '/signup',      :action => 'signup_info'
    main.login      '/login',       :action => 'login'
    main.logout     '/logout',      :action => 'logout'
  end

  # Document representations and (private) sub-resources.
  map.resources  :documents, :has_many => [:annotations],
                 :member         => {
                   :search                 => :get,
                   :remove_pages           => :post,
                   :reorder_pages          => :post,
                   :save_page_text         => :post,
                   :upload_insert_document => :post,
                   :reprocess_text         => :post,
                   :per_page_note_counts   => :get
                 },
                 :collection     => {
                   :entities     => :get,
                   :entity       => :get,
                   :dates        => :get,
                   :status       => :get,
                   :queue_length => :get,
                   :loader       => :get,
                   :preview      => :get,
                   :published    => :get,
                   :unpublished  => :get
                 }

  map.pdf        "/documents/:id/:slug.pdf",            :controller => :documents, :action => :send_pdf
  map.full_text  "/documents/:id/:slug.txt",            :controller => :documents, :action => :send_full_text
  map.page_text  "/documents/:id/pages/:page_name.txt", :controller => :documents, :action => :send_page_text, :conditions => {:method => :get}
  map.set_text   "/documents/:id/pages/:page_name.txt", :controller => :documents, :action => :set_page_text,  :conditions => {:method => :post}
  map.page_image "/documents/:id/pages/:page_name.gif", :controller => :documents, :action => :send_page_image
  map.reviewers  "/documents/reviewers/add",            :controller => :reviewers, :action => :add_reviewer, :conditions => {:method => :post}
  map.reviewers  "/documents/reviewers/remove",         :controller => :reviewers, :action => :remove_reviewer, :conditions => {:method => :post}
  map.reviewers  "/documents/reviewers/resend",         :controller => :reviewers, :action => :resend_instructions, :conditions => {:method => :post}

  # API.
  map.with_options :controller => 'api' do |api|
    api.update          '/api/documents/:id.:format', :action => 'update', :conditions => {:method => :put}
    api.destroy         '/api/documents/:id.:format', :action => 'destroy', :conditions => {:method => :delete}
    api.entities        '/api/documents/:id/entities.:format', :action => :entities
    api.projects        '/api/projects.:format',      :action => 'projects',       :conditions => {:method => :get}
    api.create_project  '/api/projects.:format',      :action => 'create_project', :conditions => {:method => :post}
    api.update_project  '/api/projects/:id.:format',  :action => 'update_project', :conditions => {:method => :put}
    api.delete_project  '/api/projects/:id.:format',  :action => 'destroy_project',:conditions => {:method => :delete}
  end

  # Bulk downloads.
  map.bulk_download '/download/*args.zip', :controller => 'download', :action => 'bulk_download'

  # Accounts and account management.
  map.resources :accounts, :member => {:resend_welcome => :post}
  map.with_options :controller => 'accounts' do |accounts|
    accounts.enable_account '/accounts/enable/:key', :action => 'enable'
    accounts.reset_password '/reset_password', :action => 'reset'
  end

  # Projects.
  map.resources :projects, :has_many => :collaborators, :member => {:documents => :get}

  # Static pages.
  map.with_options :controller => 'static' do |static|
    static.contributors   '/contributors',  :action => 'contributors'
    static.faq            '/faq',           :action => 'faq'
    static.terms          '/terms',         :action => 'terms'
    static.featured       '/featured',      :action => 'featured'
    static.privacy        '/privacy',       :action => 'privacy'
    static.home           '/home',          :action => 'home'
    static.news           '/news',          :action => 'news'
    static.opensource     '/opensource',    :action => 'opensource'
    static.about          '/about',         :action => 'about'
    static.contact        '/contact',       :action => 'contact'
    static.help           '/help',          :action => 'help'
    static.help           '/help/:page',    :action => 'help'
  end

  # Redirects.
  map.with_options :controller => 'redirect' do |move|
    move.faq              '/faq.php',       :url => '/faq'
    move.who              '/who.php',       :url => '/about'
    move.who_we_are       '/who-we-are',    :url => '/about'
    move.partner          '/partner.php',   :url => '/contributors'
    move.clips            '/clips.php',     :url => '/news'
    move.feed             '/blog/feed',     :url => 'http://blog.documentcloud.org/feed'
    move.root_feed        '/feed',          :url => 'http://blog.documentcloud.org/feed'
    move.blog             '/blog/*parts',   :url => 'http://blog.documentcloud.org/'
  end

  # Asset packages.
  Jammit::Routes.draw(map)

  # Default routes:
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
end
