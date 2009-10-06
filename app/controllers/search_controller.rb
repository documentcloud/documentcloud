class SearchController < ApplicationController
  layout 'empty'
  
  before_filter :bouncer unless Rails.development?
  
  # DocumentCloud home page...
  def index; end
  
  # Run a unified full-text/fielded search.
  def search
    query = DC::Search::Parser.new.parse(params[:query_string])
    doc_set = DC::Search.find(query)
    render :json => { 'query' => query, 'documents' => doc_set.documents }
  end
  
end