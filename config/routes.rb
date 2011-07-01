ActionController::Routing::Routes.draw do |map|

  # Internal Search API.
  map.internal_search '/search/documents.json', :controller => 'search', :action => 'documents'
  
  # Journalist workspace and surrounding HTML.
  map.with_options :controller => 'workspace' do |main|
    main.root
    main.search     '/search',        :action => 'index'
    main.search     '/search/:query', :action => 'index', :query => /.*/
    main.help       '/help',          :action => 'help'
    main.help       '/help/:page',    :action => 'help'
    main.results    '/results',       :action => 'index'
    main.signup     '/signup',        :action => 'signup_info'
    main.login      '/login',         :action => 'login'
    main.logout     '/logout',        :action => 'logout'
  end

  # Public search.
  map.public_search '/public/search', :controller => 'public', :action => 'index'
  map.public_search '/public/search/:query', :controller => 'public', :action => 'index', :query => /.*/
  
  # Document representations and (private) sub-resources.
  map.resources  :documents, :has_many => [:annotations],
    :member => {
      :search                 => :get,
      :remove_pages           => :post,
      :redact_pages           => :post,
      :reorder_pages          => :post,
      :save_page_text         => :post,
      :upload_insert_document => :post,
      :reprocess_text         => :post,
      :per_page_note_counts   => :get,
      :mentions               => :get
    },
    :collection => {
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

  # Search Embeds.
  map.with_options :controller => :search, :action => :embed do |embed|
    options = {:q => /[^\/;,?]*/, :options => /p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)(-secure)?/}
    embed.search_embed "/search/embed/:q/:options.:format", options
    embed.search_embed "/search/embed/:options.:format", options
  end

  # Reviewers.
  map.resources :reviewers, :collection => {
    :preview_email => :get,
    :send_email    => :post
  }

  # API.
  map.with_options :controller => 'api' do |api|
    api.update          '/api/documents/:id.:format', :action => 'update', :conditions => {:method => :put}
    api.destroy         '/api/documents/:id.:format', :action => 'destroy', :conditions => {:method => :delete}
    api.entities        '/api/documents/:id/entities.:format', :action => :entities
    api.note            '/api/documents/:id/note/:note_id.:format', :action => :note, :conditions => {:method => :get}
    api.projects        '/api/projects.:format',      :action => 'projects',       :conditions => {:method => :get}
    api.create_project  '/api/projects.:format',      :action => 'create_project', :conditions => {:method => :post}
    api.update_project  '/api/projects/:id.:format',  :action => 'update_project', :conditions => {:method => :put}
    api.delete_project  '/api/projects/:id.:format',  :action => 'destroy_project',:conditions => {:method => :delete}
  end

  # Bulk downloads.
  map.bulk_download '/download/*args.zip', :controller => 'download', :action => 'bulk_download'

  # Accounts and account management.
  map.resources :accounts, :member      => {:resend_welcome => :post},
                           :collection  => {:logged_in => :get}
  map.with_options :controller => 'accounts' do |accounts|
    accounts.enable_account '/accounts/enable/:key', :action => 'enable'
    accounts.reset_password '/reset_password', :action => 'reset'
  end

  # Projects.
  map.resources :projects, :has_many => :collaborators, :member => {
    :documents        => :get,
    :add_documents    => :post,
    :remove_documents => :post
  }

  # Home pages.
  map.with_options :controller => 'home' do |home|
    home.contributors   '/contributors',  :action => 'contributors'
    home.faq            '/faq',           :action => 'faq'
    home.terms          '/terms',         :action => 'terms'
    home.featured       '/featured',      :action => 'featured'
    home.privacy        '/privacy',       :action => 'privacy'
    home.home           '/home',          :action => 'index'
    home.news           '/news',          :action => 'news'
    home.opensource     '/opensource',    :action => 'opensource'
    home.about          '/about',         :action => 'about'
    home.contact        '/contact',       :action => 'contact'
    home.help           '/help',          :action => 'help'
    home.help           '/help/:page',    :action => 'help'
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
