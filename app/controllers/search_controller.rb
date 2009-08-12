class SearchController < ApplicationController
  
  def search
    query = DC::Search::Parser.new.parse(params[:query_string])
    doc_set = DC::Search.find(query)
    doc_set.populate_metadata
    render :json => {
      'query' => query,
      'results' => doc_set
    }
  end
  
end