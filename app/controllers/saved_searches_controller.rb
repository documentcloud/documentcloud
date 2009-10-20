class SavedSearchesController < ApplicationController
    
  before_filter :login_required
  
  def index
    json 'saved_searches' => [ # current_account.saved_searches
      {'id' => 1, 'query' => 'person:rizzo waterboarding'},
      {'id' => 2, 'query' => 'position:"Attorney General" ashcroft "patriot act"'}
    ]
  end
  
  def create
    json current_account.saved_searches.create(pick_params(:query))
  end
  
  def destroy
    current_account.saved_searches.find(params[:id]).destroy
    json nil
  end
  
end