ActionController::Routing::Routes.draw do |map|

  # Internal Search API.
  map.search '/search.json', :controller => 'search', :action => 'search'

  # API Controller uses default routes, for now.

  # Workspace and surrounding HTML.
  map.with_options :controller => 'workspace' do |main|
    main.root
    main.home       '/home',        :action => 'home'
    main.results    '/results',     :action => 'index'
    main.signup     '/signup',      :action => 'signup'
    main.login      '/login',       :action => 'login'
    main.logout     '/logout',      :action => 'logout'
    main.todo       '/todo',        :action => 'todo'
  end

  # Document representations and sub-resources.
  map.resources :documents,
                :collection => {:metadata => :get},
                :member     => {:thumbnail => :get, :search => :get}
  map.page_text "/documents/:id/:page_name.txt", :controller => :documents, :action => :page_text

  # Bulk downloads.
  map.bulk_download '/download/*args.zip', :controller => 'download', :action => 'bulk_download'

  # Accounts and account management.
  map.resources :accounts
  map.with_options :controller => 'accounts' do |accounts|
    accounts.enable_account '/accounts/enable/:key', :action => 'enable'
  end

  # Saved Searches.
  map.resources :saved_searches

  # Labels.
  map.resources :labels, :member => {:documents => :get}

  # Asset packages.
  Jammit::Routes.draw(map)

  # Default routes:
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
end
