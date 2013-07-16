DC::Application.routes.draw do


  # homepage
  get '/' => 'workspace#index'

  # Internal Search API.
  get '/search/documents.json' => 'search#documents'

  # Search Embeds.
  get '/search/embed/:q/:options.:format' => 'search#embed', :q => /[^\/;,?]*/, :options => /p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)(-secure)?/
  get '/search/embed/:options.:format' => 'search#embed',    :q => /[^\/;,?]*/, :options => /p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)(-secure)?/

  # Journalist workspace and surrounding HTML.
  get '/search' => 'workspace#index'
  get '/search/preview' => 'search#preview', :as => :preview
  get '/search/:query' => 'workspace#index', :query => /.*/
  get '/help' => 'workspace#help'
  get '/help/:page' => 'workspace#help'
  get '/results' => 'workspace#index', :as => :results

  # login / logout
  get '/signup' => 'authentication#signup_info', :as => :signup
  get '/login' => 'authentication#login', :as => :login
  get '/logout' => 'authentication#logout', :as => :logout
  # Third party auth via OmniAuth
  get '/auth/:action' => 'authentication#index'
  get '/auth/:provider' => 'authentication#blank'
  get '/auth/:provider/callback' => 'authentication#callback'
  get '/auth/remote_data/:document_id' => 'authentication#remote_data'

  # Public search.
  get '/public/search' => 'public#index'
  get '/public/search/:query' => 'public#index', :query => /.*/

  # API.
  namespace :api do
    
    # match 'documents/:id.:format' => 'api#cors_options', :as => :document, :via => [:get, :put, :delete], :via => :options

    # get 'documents/:id/entities.:format' => 'api#cors_options', :as => :entities, :allowed_methods => [:get], :via => 
    #   get 'documents/:id/note/:note_id.:format' => 'api#cors_options', :as => :note, :allowed_methods => [:get], :via => 
    #   get 'documents/:id/notes/:note_id.:format' => 'api#cors_options', :as => :notes, :allowed_methods => [:get], :via => 
    #   get 'documents/pending.:format' => 'api#cors_options', :as => :pending, :allowed_methods => [:get], :via => 
    #   get 'projects/:id.:format' => 'api#cors_options', :as => :project, :allowed_methods => [:get, :put, :delete], :via => 
    #   get 'projects.:format' => 'api#cors_options', :as => :projects, :allowed_methods => [:get, :post], :via => 
    #   get 'search.:format' => 'api#cors_options', :as => :search, :allowed_methods => [:get], :via => 


    # put 'documents/:id.:format' => 'api#update', :as => :update, :via => :put

    # get 'documents/:id.:format' => 'api#destroy', :as => :destroy, :via => :delete
    # get 'documents/:id/entities.:format' => 'api#entities', :as => :entities
    # get 'documents/:id/note/:note_id.:format' => 'api#notes', :as => :note, :via => :get
    # get 'documents/:id/notes/:note_id.:format' => 'api#notes', :as => :notes, :via => :get
    # get 'documents/pending.:format' => 'api#pending', :as => :pending
    # get 'projects/:id.:format' => 'api#project', :as => :project, :via => :get
    # get 'projects.:format' => 'api#projects', :as => :projects, :via => :get
    # post 'projects.:format' => 'api#create_project', :as => :create_project
    # put 'projects/:id.:format' => 'api#update_project', :as => :update_project
    # delete 'projects/:id.:format' => 'api#destroy_project', :as => :delete_project
  end

  resources :featured do
    collection { post :present_order }
  end

  # get '/documents/:document_id/annotations/:id.:format' => 'annotations#cors_options', :as => :annotation, :allowed_methods => [:put, :delete, :post], :via => :options
  # get '/documents/:document_id/annotations.:format' => 'annotations#cors_options', :as => :annotations, :allowed_methods => [:get, :post], :via => 
  # resources :documents do
  #   collection do
  # get :status
  # get :loader
  # get :queue_length
  # get :preview
  # get :published
  # get :entity
  # get :unpublished
  # get :entities
  # get :dates
  # get :occurrence
  # end
  #   member do
  # post :upload_insert_document
  # post :reprocess_text
  # post :remove_pages
  # get :search
  # get :per_page_note_counts
  # post :redact_pages
  # get :mentions
  # post :reorder_pages
  # post :save_page_text
  # end
  
  # end

  get '/documents/:id/:slug.pdf' => 'documents#send_pdf'
  get '/documents/:id/:slug.txt' => 'documents#send_full_text'
  get '/documents/:id/preview/' => 'documents#preview'
  get '/documents/:id/pages/:page_name.txt' => 'documents#send_page_text'
  post '/documents/:id/pages/:page_name.txt' => 'documents#set_page_text'
  get '/documents/:id/pages/:page_name.gif' => 'documents#send_page_image'

  # Print notes.
  get '/notes/print' => 'annotations#print', :as => :print_notes

  # Reviewers.
  resources :reviewers do
    collection {
      post :send_email
      get :preview_email
    }
  end

  # Bulk downloads.
  get '/download/*args.zip' => 'download#bulk_download', :as => :bulk_download

  # Accounts and account management.
  resources :accounts do
    collection {
      get :logged_in
    }
    member {
      post :resend_welcome
    }
  end
  get '/accounts/enable/:key' => 'accounts#enable', :as => :enable_account
  get '/reset_password' => 'accounts#reset', :as => :reset_password

  # Projects.
  resources :projects do
    member {
      post :add_documents
      post :remove_documents
      get :documents
    }
  end

  # Home pages.
  get '/contributors' => 'home#contributors', :as => :contributors
  get '/faq' => 'home#faq'
  get '/terms' => 'home#terms', :as => :terms
  get '/privacy' => 'home#privacy', :as => :privacy
  get '/p3p.:format' => 'home#p3p', :as => :p3p
  get '/home' => 'home#index', :as => :home
  get '/news' => 'home#news', :as => :news
  get '/opensource' => 'home#opensource', :as => :opensource
  get '/about' => 'home#about', :as => :about
  get '/contact' => 'home#contact', :as => :contact
  get '/help' => 'home#help'
  get '/help/:page' => 'home#help'
  get '/multilanguage' => 'home#multilanguage', :as => :multilanguage

  # Redirects.
  get '/faq.php' => 'redirect#index', :url => '/faq'
  get '/who.php' => 'redirect#index', :as => :who, :url => '/about'
  get '/who-we-are' => 'redirect#index', :as => :who_we_are, :url => '/about'
  get '/partner.php' => 'redirect#index', :as => :partner, :url => '/contributors'
  get '/clips.php' => 'redirect#index', :as => :clips, :url => '/news'
  get '/blog/feed' => 'redirect#index', :as => :feed, :url => 'http://blog.documentcloud.org/feed'
  get '/feed' => 'redirect#index', :as => :root_feed, :url => 'http://blog.documentcloud.org/feed'
  get '/blog/*parts' => 'redirect#index', :as => :blog, :url => 'http://blog.documentcloud.org/'
  get '/:controller(/:action(/:id))'
  get ':controller/:action.:format' => '#index'

end
