
DC::Application.routes.draw do
  def you_are_documentcloud?
    File.exist? File.join(Rails.root, 'secrets', 'documentcloud.yep')
    # DC::Application.config.you_are_documentcloud is always returning false in here
  end

  # Homepage
  get '/', to: 'home#index', as: 'homepage'

  # Embed loaders
  get '/embed/loader/enhance', to: 'embed#enhance', as: 'embed_enhance'
  get '/:object/loader',       to: 'embed#loader',  as: 'embed_loader',
                               object: /viewer|notes|embed/

  # Internal search API
  get '/search/documents.:format', to: 'search#documents'

  # Search embeds
  get '/search/embed/:q/:options.:format', to: 'search#embed', q: /[^\/;,?]*/,
                                           options: /p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)(-secure)?/
  get '/search/embed/:options.:format',    to: 'search#embed', q: /[^\/;,?]*/,
                                           options: /p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)(-secure)?/

  # Journalist workspace and surrounding HTML
  get '/search',                   to: 'workspace#index', as: 'search'
  get '/search/preview',           to: 'search#preview',  as: 'preview'
  get '/search/restricted_count',  to: 'search#restricted_count'
  get '/search(/:query)(/p:page)', to: 'workspace#index', as: 'workspace'
  get '/help',                     to: 'workspace#help'
  get '/help/:page',               to: 'workspace#help'
  get '/results',                  to: 'workspace#index', as: 'results'

  # Authentication with DocumentCloud Accounts service
  if you_are_documentcloud?
    get 'auth/documentcloud', to: 'sessions#new', as: :accounts_login
    get 'auth/logout', to: 'sessions#destroy', as: :accounts_logout
    get 'auth/:provider/callback', to: 'sessions#create', as: :accounts_callback
    get 'auth/failure', to: 'sessions#failure', as: :accounts_failure
    get 'auth/forgot' => redirect("#{DC::SECRETS['omniauth']['documentcloud']['site']}/login/forgot"), as: :accounts_forgot_password
    # Override current routes
    match '/login', to: 'sessions#new', via: [:get, :post], as: 'login'
    get '/logout', to: 'sessions#destroy', as: 'logout'
  else
    # Legacy Authentication
    scope(controller: 'authentication') do
      match '/login', action: 'login', via: [:get, :post], as: 'login'
      get '/logout', action: 'logout', as: 'logout'
      get '/auth/remote_data/:document_id', action: 'remote_data'
    end
  end

  # Switch membership/organization
  get '/sessions/switch_to/:organization_id-:organization_slug',
      to: 'sessions#switch_membership_by_organization',
      as: 'switch_organization',
      organization_id: /\d+/, organization_slug: /[\p{Letter}\p{Number}\-]+/

  # Public search
  get '/public/search(/:query)(/:page)', to: 'public#index', as: 'public_search'

  # API
  scope(:api, controller: 'api') do
    scope(via: 'options', action: 'cors_options') do
      match 'documents/pending.:format',            allowed_methods: [:get]
      match 'documents/:id.:format',                allowed_methods: [:get, :put, :delete]
      match 'documents/:id/entities.:format',       allowed_methods: [:get]
      match 'documents/:id/note/:note_id.:format',  allowed_methods: [:get]
      match 'documents/:id/notes/:note_id.:format', allowed_methods: [:get]
      match 'projects/:id.:format',                 allowed_methods: [:get, :put, :delete]
      match 'projects.:format',                     allowed_methods: [:get, :post]
      match 'search.:format',                       allowed_methods: [:get]
    end

    put 'documents/:id.:format',                action: 'update'
    delete 'documents/:id.:format',             action: 'destroy'
    get 'documents/:id/entities.:format',       action: 'entities'
    get 'documents/:id/note/:note_id.:format',  action: 'notes'
    get 'documents/:id/notes/:note_id.:format', action: 'notes'
    get 'documents/pending.:format',            action: 'pending'
    get 'projects/:id.:format',                 action: 'project'
    get 'projects.:format',                     action: 'projects'
    post 'projects.:format',                    action: 'create_project'
    put 'projects/:id.:format',                 action: 'update_project'
    delete 'projects/:id.:format',              action: 'destroy_project'
  end

  resources :featured do
    collection do
      post 'present_order'
    end
  end

  get '/documents', to: redirect('/public/search')
  resources :documents do

    resources :annotations do
      member do
        match '(*all)', action: 'cors_options', via: 'options', allowed_methods: [:put, :delete, :post]
      end
    end
    resource :annotation do
      match '(*all)', action: 'cors_options', via: 'options', allowed_methods: [:get, :post]
    end

    # in order not to clobber existing routes
    # resources :pages
    # When we're using proper routes, we'll also need to update
    # `ApiController#resource_embeddable?` to make pages act like notes, and
    # untangle `params[:page_number|:id|:document_id]` in `PagesController`

    collection do
      get 'status'
      get 'queue_length'
      get 'preview'
      get 'published'
      get 'entity'
      get 'unpublished'
      get 'entities'
      get 'dates'
      get 'occurrence'
    end
    member do
      post 'upload_insert_document'
      post 'reprocess_text'
      post 'remove_pages'
      get  'search'
      get  'per_page_note_counts'
      post 'redact_pages'
      get  'mentions'
      post 'reorder_pages'
      post 'save_page_text'
      get  'preview'
      get  ':slug.pdf',            action: 'send_pdf'
      get  ':slug.txt',            action: 'send_full_text'
      get  'pages/:page_name.txt', action: 'send_page_text'
      post 'pages/:page_name.txt', action: 'set_page_text'
      get  'pages/:page_name.gif', action: 'send_page_image'
      get  'pages/:page_number.:format', to: "pages#show"
    end
  end

  # # Print notes
  get '/notes/print', to: 'annotations#print', as: 'print_notes'

  # Reviewers
  resources :reviewers do
    collection do
      post 'send_email'
      get  'preview_email'
    end
  end

  # Bulk downloads
  get '/download/*args.zip', to: 'download#bulk_download', as: 'bulk_download'

  # Accounts and account management
  get    '/accounts/mailboxes',     to: 'accounts#mailboxes',       as: 'mailboxes'
  post   '/accounts/mailboxes',     to: 'accounts#create_mailbox',  as: 'create_mailbox'
  delete '/accounts/mailboxes/:id', to: 'accounts#revoke_mailbox',  as: 'revoke_mailbox'
  resources :accounts do
    collection do
      get 'logged_in'
    end
    member do
      post 'resend_welcome'
    end
  end

  match '/accounts/enable/:key', to: 'accounts#enable', via: [:get, :post], as: 'enable_account'

  if you_are_documentcloud?
    get '/reset_password' => redirect("#{DC::SECRETS['omniauth']['documentcloud']['site']}/login/forgot"), as: :reset_password
  else
    match '/reset_password',       to: 'accounts#reset',  via: [:get, :post], as: 'reset_password'
  end

  if you_are_documentcloud?
    get '/accounts' => redirect("#{DC::SECRETS['omniauth']['documentcloud']['site']}/settings"), as: :account_settings
  end

  # Account requests
  get '/signup', to: 'redirect#index', url: '/plans/apply', as: 'signup'
  get '/apply',  to: 'redirect#index', url: '/plans/apply', as: 'apply'

  # Organizations management
  resources :organizations, only: [:update]

  # Projects
  resources :projects do
    member do
      post 'add_documents'
      post 'remove_documents'
      get  'documents'
    end
    resources :collaborators, only: [:create, :destroy, :accept]
  end

  # Home pages
  get '/contributors',          to: 'home#contributors',  as: 'contributors'
  get '/faq',                   to: 'home#faq'
  get '/terms/api/(/:version)', to: 'home#api_terms',     as: 'api_terms', version: /[\d\.]+/
  get '/terms(/:version)',      to: 'home#terms',         as: 'terms',     version: /[\d\.]+/
  get '/privacy',               to: 'home#privacy',       as: 'privacy'
  get '/p3p.:format',           to: 'home#p3p',           as: 'p3p'
  get '/home',                  to: 'home#index',         as: 'home'
  get '/opensource',            to: 'home#opensource',    as: 'opensource'
  get '/about',                 to: 'home#about',         as: 'about'
  get '/contact',               to: 'home#contact',       as: 'contact'
  get '/multilanguage',         to: 'home#multilanguage', as: 'multilanguage'

  # Redirects
  get '/index.php',             to: 'redirect#index',                     url: '/'
  get '/document-contributors', to: 'redirect#index',                     url: '/contributors'
  get '/faq.php',               to: 'redirect#index',                     url: '/faq'
  get '/who.php',               to: 'redirect#index', as: 'who',          url: '/about'
  get '/who-we-are',            to: 'redirect#index', as: 'who_we_are',   url: '/about'
  get '/partner.php',           to: 'redirect#index', as: 'partner',      url: '/contributors'
  get '/blog/feed',             to: 'redirect#index', as: 'feed',         url: 'https://blog.documentcloud.org/feed'
  get '/feed',                  to: 'redirect#index', as: 'root_feed',    url: 'https://blog.documentcloud.org/feed'
  get '/blog/*parts',           to: 'redirect#index', as: 'blog',         url: 'https://blog.documentcloud.org/'
  get '/clips.php',             to: 'redirect#index', as: 'clips',        url: 'https://blog.documentcloud.org/'
  get '/news',                  to: 'redirect#index', as: 'news',         url: 'https://blog.documentcloud.org/'
  get '/blog',                  to: 'redirect#index',                     url: 'https://blog.documentcloud.org/'

  # Donations
  get  '/donate',                to: 'donate#index',  as: 'donate'
  get  '/donate/prolix',         to: 'donate#index',  as: 'donate_prolix', prolix: true
  post '/donate',                to: 'donate#charge', as: 'donate_charge'
  get  '/donate/thanks',         to: 'donate#thanks', as: 'donate_thanks'
  get  '/donate/thanks/preview', to: 'donate#thanks', as: 'donate_thanks_preview', preview: true

  # Admin section
  get '/admin', to: 'admin#index'
  get '/admin/health_check/:subject/:env', to: 'admin#health_check', subject: /page_embed/, env: /production|staging/
  get '/admin/signup', to: 'admin#signup', as: 'admin_signup'
  get '/admin/organizations/:slug', as: 'admin_organization', to: 'admin#organization'
  get '/admin/organizations/?',      as: 'admin_organizations', to: 'admin#organizations'
  
  # Standard fallback routes
  match '/:controller(/:action(/:id))', via: [:get, :post]
  get ':controller/:action.:format'

  root to: 'home#index'
end

# Magic invocation to ask engines to add their routes
Rails.application.load_additional_routes
