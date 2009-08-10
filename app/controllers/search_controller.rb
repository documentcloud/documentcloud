class SearchController < ApplicationController
  
  def search
    render :json => {
      'documents' => DC::Search.find(params[:query_string]).map {|d| d.to_json }
    }
  end
  
end