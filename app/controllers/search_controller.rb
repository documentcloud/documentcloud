class SearchController < ApplicationController
  include DC::Search::Controller

  before_filter :bouncer if Rails.env.staging?

  FIELD_STRIP = /\S+:\s*/

  def documents
    perform_search :include_facets => params[:include_facets]
    results = {'query' => @query, 'documents' => @documents}
    results['facets'] = @query.facets if params[:include_facets]
    json results
  end

  def facets
    perform_search :exclude_documents => true, 
                   :include_facets => true
    results = {'query' => @query, 'facets' => @query.facets}
    json results
  end
  
  def notes
    params[:q].gsub!(FIELD_STRIP, '') if params[:q]
    perform_search
    render :json => {'query' => @query, 'documents' => @documents}
  end

  def related_documents
    query = {
      :page_size => params[:page_size] ? params[:page_size].to_i : DEFAULT_PAGE_SIZE,
      :order => params[:order] || DEFAULT_ORDER,
      :page => params[:page] ? params[:page].to_i : 1
    }
    document = Document.find(params[:document_id].to_i)
    documents = Document.search("", {:related_document => document}).results
    results = {:query => query, :documents => documents}
    json results
  end
  
end