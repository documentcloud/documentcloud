class SearchController < ApplicationController
  include DC::Search::Controller

  before_filter :bouncer unless Rails.env.development?

  NOTE_STRIP = /\Anotes:\s+/

  def documents
    perform_search
    render :json => {'query' => @query, 'documents' => @documents}
  end

  def notes
    params[:q].sub!(NOTE_STRIP, '')
    perform_search
    render :json => {'query' => @query, 'documents' => @documents}
  end

end