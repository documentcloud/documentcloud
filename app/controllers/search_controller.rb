class SearchController < ApplicationController
  include DC::Search::Controller

  before_filter :bouncer if Rails.env.staging?

  FIELD_STRIP = /\S+:\s*/

  def documents
    perform_search :include_facets => params[:include_facets]
    results = {:query => @query, :documents => @documents}
    results[:facets] = @query.facets if params[:include_facets]
    results[:source_document] = @source_document if params.include? :include_source_document
    respond_to do |format|
      format.js do
        js = "dc.loadJSON(#{results.to_json});"
        cache_page js
        render :js => js
      end
      format.json do
        json results
      end
    end
  end

  def facets
    perform_search :exclude_documents => true,
                   :include_facets => true
    results = {:query => @query, :facets => @query.facets}
    json results
  end

end