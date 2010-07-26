class SearchController < ApplicationController
  include DC::Search::Controller

  before_filter :bouncer if Rails.env.staging?

  FIELD_STRIP = /\S+:\s*/

  def documents
    perform_search :include_facets => params[:include_facets]
    results = {:query => @query, :documents => @documents}
    results[:facets] = @query.facets if params[:include_facets]
    json results
  end

  def facets
    perform_search :exclude_documents => true, 
                   :include_facets => true
    results = {:query => @query, :facets => @query.facets}
    json results
  end
  
  def notes
    params[:q].gsub!(FIELD_STRIP, '') if params[:q]
    perform_search
    render :json => {:query => @query, :documents => @documents}
  end

  def related_documents
    perform_search :include_facets => params[:include_facets]
    results = {:query => @query, :documents => @documents}
    results[:original_document] = @related_document if params.include? :need_original_document
    results[:facets] = @query.facets if params[:include_facets]
    
    json results
  end
  
end