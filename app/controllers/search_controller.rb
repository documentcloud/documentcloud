class SearchController < ApplicationController
  include DC::Search::Controller

  before_filter :bouncer unless Rails.env.development?

  def search
    perform_search
    respond_to do |format|
      format.json do
        render :json => {'query' => @query, 'documents' => @documents}
      end
    end
  end

end