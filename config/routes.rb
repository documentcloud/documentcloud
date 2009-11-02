ActionController::Routing::Routes.draw do |map|
  
  # Search API.
  map.with_options :controller => 'search' do |search|
    search.api '/search.:format', :action => 'search'
  end  
  
  # Workspace and surrounding HTML.
  map.with_options :controller => 'workspace' do |main|
    main.root
    main.results '/results',  :action => 'index'
    main.signup  '/signup',   :action => 'signup' 
    main.login   '/login',    :action => 'login' 
    main.logout  '/logout',   :action => 'logout'
    main.todo    '/todo',     :action => 'todo'
  end
  
  # Document representations and sub-resources.
  map.resources :documents, 
                :collection => {:metadata => :get},
                :member => {:thumbnail => :get}
  
  # Accounts and account management.       
  map.resources :accounts
  map.with_options :controller => 'accounts' do |accounts|
    accounts.enable_account '/accounts/enable/:key', :action => 'enable'
  end
  
  # Saved Searches.
  map.resources :saved_searches
  
  # Labels.
  map.resources :labels, :member => {:documents => :get}
  
  # Default routes:
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
end
