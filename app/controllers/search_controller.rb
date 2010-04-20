class SearchController < ApplicationController
  include DC::Search::Controller

  before_filter :bouncer if Rails.env.staging?

  FIELD_STRIP = /\S+:\s*/

  def documents
    perform_search
    results = {'query' => @query, 'documents' => @documents}
    results['facets'] = @query.facets if params[:facets]
    render :json => results
  end

  def notes
    params[:q].gsub!(FIELD_STRIP, '') if params[:q]
    perform_search
    render :json => {'query' => @query, 'documents' => @documents}
  end

end