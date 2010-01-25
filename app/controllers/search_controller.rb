class SearchController < ApplicationController
  include DC::Search::Controller

  before_filter :bouncer unless Rails.env.development?

  FIELD_STRIP = /\S+:\s*/

  def documents
    perform_search
    render :json => {'query' => @query, 'documents' => @documents}
  end

  def notes
    params[:q].gsub!(FIELD_STRIP, '')
    perform_search
    render :json => {'query' => @query, 'documents' => @documents}
  end

end