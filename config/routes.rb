ActionController::Routing::Routes.draw do |map|

  # Internal Search API.
  map.internal_search '/search/documents.json', :controller => 'search', :action => 'documents'
  
  # Search Embeds.
  map.with_options :controller => :search, :action => :embed do |embed|
    options = {:q => /[^\/;,?]*/, :options => /p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)(-secure)?/}
    embed.search_embed "/search/embed/:q/:options.:format", options
    embed.search_embed "/search/embed/:options.:format", options
  end
  
  # Journalist workspace and surrounding HTML.
  map.with_options :controller => 'workspace' do |main|
    main.root
    main.search     '/search',        :action => 'index'
    main.routes     '/search/:action.json', :controller => :search, :format => :json
    main.routes     '/search/:action.js',   :controller => :search, :format => :js
    main.preview    '/search/preview',      :controller => :search, :action => :preview
    main.search     '/search/:query', :action => 'index', :query => /.*/
    main.help       '/help',          :action => 'help'
    main.help       '/help/:page',    :action => 'help'
    main.results    '/results',       :action => 'index'
  end
  
  # Third party logins via OmitAuth library
  map.with_options :controller => 'authentication' do | auth |
    auth.signup     '/signup',        :action => 'signup_info'
    auth.login      '/login',         :action => 'login'
    auth.logout     '/logout',        :action => 'logout'

    auth.connect '/auth/:action'
    auth.connect '/auth/:provider',          :action => :blank
    auth.connect '/auth/:provider/callback', :action => :callback
    auth.connect '/auth/remote_data/:document_id', :action=>:remote_data
  end

  # Public search.
  map.public_search '/public/search', :controller => 'public', :action => 'index'
  map.public_search '/public/search/:query', :controller => 'public', :action => 'index', :query => /.*/

  # API.
  map.with_options :controller => 'api' do |api|
    api.with_options :conditions => {:method => :options}, :action => 'cors_options' do |cors_api|
      cors_api.document     '/api/documents/:id.:format', :allowed_methods => [ :get, :put, :delete ]
      cors_api.entities     '/api/documents/:id/entities.:format', :allowed_methods => [ :get ]
      cors_api.note         '/api/documents/:id/note/:note_id.:format', :allowed_methods => [ :get ]
      cors_api.notes        '/api/documents/:id/notes/:note_id.:format', :allowed_methods => [ :get ]
      cors_api.pending      '/api/documents/pending.:format', :allowed_methods => [ :get ]
      cors_api.project      '/api/projects/:id.:format', :allowed_methods => [ :get, :put, :delete ]
      cors_api.projects     '/api/projects.:format', :allowed_methods => [ :get, :post ]
    end

    api.update          '/api/documents/:id.:format', :action => 'update', :conditions => {:method => :put}
    api.destroy         '/api/documents/:id.:format', :action => 'destroy', :conditions => {:method => :delete}
    api.entities        '/api/documents/:id/entities.:format', :action => :entities
    api.note            '/api/documents/:id/note/:note_id.:format', :action => :notes, :conditions => {:method => :get}
    api.notes           '/api/documents/:id/notes/:note_id.:format', :action => :notes, :conditions => {:method => :get}
    api.pending         '/api/documents/pending.:format', :action => :pending
    api.project         '/api/projects/:id.:format',  :action => 'project',        :conditions => {:method => :get}
    api.projects        '/api/projects.:format',      :action => 'projects',       :conditions => {:method => :get}
    api.create_project  '/api/projects.:format',      :action => 'create_project', :conditions => {:method => :post}
    api.update_project  '/api/projects/:id.:format',  :action => 'update_project', :conditions => {:method => :put}
    api.delete_project  '/api/projects/:id.:format',  :action => 'destroy_project',:conditions => {:method => :delete}
  end


  map.resources :featured, :collection => { :present_order => :any }
  
  map.with_options :controller=>:annotations do | annot |
    annot.with_options :conditions => {:method => :options}, :action => 'cors_options' do |cors_api|
      cors_api.annotation '/documents/:document_id/annotations/:id.:format', :allowed_methods=>[:put,:delete,:post]
      cors_api.annotations '/documents/:document_id/annotations.:format', :allowed_methods=>[:get,:post]
    end
  end

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
      :occurrence   => :get,
      :status       => :get,
      :queue_length => :get,
      :loader       => :get,
      :preview      => :get,
      :published    => :get,
      :unpublished  => :get
    }

  map.pdf        "/documents/:id/:slug.pdf",            :controller => :documents, :action => :send_pdf
  map.full_text  "/documents/:id/:slug.txt",            :controller => :documents, :action => :send_full_text
  map.page_text  "/documents/:id/preview/",             :controller => :documents, :action => :preview, :conditions => {:method => :get}
  map.page_text  "/documents/:id/pages/:page_name.txt", :controller => :documents, :action => :send_page_text, :conditions => {:method => :get}
  map.set_text   "/documents/:id/pages/:page_name.txt", :controller => :documents, :action => :set_page_text,  :conditions => {:method => :post}
  map.page_image "/documents/:id/pages/:page_name.gif", :controller => :documents, :action => :send_page_image

  # Print notes.
  map.print_notes "/notes/print", :controller => :annotations, :action => 'print'

  # Reviewers.
  map.resources :reviewers, :collection => {
    :preview_email => :get,
    :send_email    => :post
  }

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
    home.privacy        '/privacy',       :action => 'privacy'
    home.p3p            '/p3p.:format',   :action => 'p3p'
    home.home           '/home',          :action => 'index'
    home.news           '/news',          :action => 'news'
    home.opensource     '/opensource',    :action => 'opensource'
    home.about          '/about',         :action => 'about'
    home.contact        '/contact',       :action => 'contact'
    home.help           '/help',          :action => 'help'
    home.help           '/help/:page',    :action => 'help'
    home.multilanguage  '/multilanguage', :action => 'multilanguage'
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
