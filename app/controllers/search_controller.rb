class SearchController < ApplicationController
  layout 'empty'
  
  # DocumentCloud home page...
  def index
  end
  
  def search
    query = DC::Search::Parser.new.parse(params[:query_string])
    doc_set = DC::Search.find(query)
    render :json => { 'query' => query, 'documents' => doc_set.documents }
  end
  
end