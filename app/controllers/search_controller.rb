class SearchController < ApplicationController
  
  def search
    query = DC::Search::Parser.new.parse(params[:query_string])
    render :json => {
      'query' => query,
      'documents' => DC::Search.find(query)
    }
  end
  
end