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
      format.json do
        json results
      end
    end
  end

  def embed
    groups = params[:options].match(/p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)/)
    _, params[:page], params[:per_page], params[:order], params[:organization_id] = *groups
    perform_search :include_facets => params[:include_facets]
    results             = {:query => @query, :documents => @documents}
    results[:query]     = params[:q] || ""
    results[:total]     = @query.total
    results[:page]      = @query.page
    results[:per_page]  = @query.per_page
    results[:documents] = @documents.map do |d|
      not_owned = d.organization_id != params[:organization_id].to_i
      d.canonical API_OPTIONS.merge(:contributor => not_owned, :allow_detected => true)
    end
    results[:dc_url]    = "#{DC.server_root(:ssl => false).sub('s3', 'www')}"
    js                  = "dc.embed.callback(#{results.to_json});"
    cache_page js unless request.ssl?
    render :js => js
  end

  def restricted_count
    params[:q] += " filter:restricted"
    perform_search
    json :restricted_count => @query.total
  end

  def facets
    perform_search :exclude_documents => true,
                   :include_facets => true
    results = {:query => @query, :facets => @query.facets}
    json results
  end

  def preview
    @query   = params[:query]
    @slug    = params[:slug]
    @options = params[:options]
  end

  def loader
    render :action => 'loader', :content_type => :js
  end

end