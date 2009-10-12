class SearchController < ApplicationController
  layout 'empty'
  
  before_filter :bouncer unless Rails.development?
  
  # DocumentCloud home page...
  def index; end
  
  # Run a unified full-text/fielded search.
  def search
    opts  = {}
    opts  = {:account_id => current_account.id, :organization_id => current_organization.id} if logged_in?
    query = DC::Search::Parser.new.parse(params[:query_string])
    docs  = DC::Search.find(query, opts)
    render :json => { 'query' => query, 'documents' => docs }
  end
  
end