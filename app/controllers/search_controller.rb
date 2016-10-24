class SearchController < ApplicationController
  include DC::Search::Controller

  before_action :bouncer if exclusive_access?

  FIELD_STRIP = /\S+:\s*/

  def documents
    set_cache_statement("public, max-age=600") unless logged_in?
    perform_search pick(params, :mentions)
    results = {:query => @query, :documents => @documents}
    respond_to do |format|
      format.json do
        json results
      end
    end
  end

  def embed
    return bad_request unless params[:options]
    set_cache_statement("public, max-age=600") unless logged_in?
    groups = params[:options].match(/p-(\d+)-per-(\d+)-order-(\w+)-org-(\d+)/)
    _, params[:page], params[:per_page], params[:order], params[:organization_id] = *groups
    perform_search
    results             = {:query => @query, :documents => @documents}
    results[:query]     = params[:q] || ""
    results[:total]     = @query.total
    results[:page]      = @query.page
    results[:per_page]  = @query.per_page
    results[:documents] = @documents.map do |d|
      not_owned = d.organization_id != params[:organization_id].to_i
      d.canonical API_OPTIONS.merge(:contributor => not_owned, :allow_ssl => true)
    end
    results[:dc_url] = "#{DC.server_root}"
    js = "dc.embed.callback(#{results.to_json});"
    if params[:q].length > 255
      head :bad_request and return
    end
    #cache_page js unless request.ssl?
    set_cache_statement("public, max-age=150") unless logged_in?
    render :js => js
  end

  def restricted_count
    params[:q] = (params[:q] || "") + " filter:restricted"
    perform_search
    json :restricted_count => @query.total
  end

  # def facets
  #   perform_search :exclude_documents => true,
  #                  :include_facets => true
  #   results = {:query => @query, :facets => @query.facets}
  #   json results
  # end

  def preview
    @query   = params[:query]
    @slug    = params[:slug]
    @options = params[:options]
  end

end
