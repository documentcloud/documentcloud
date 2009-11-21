class SearchController < ApplicationController
  layout 'empty'

  before_filter :bouncer unless Rails.development?

  def api_search
    perform_search
    respond_to do |format|
      format.json do
        render :json => {'documents' => @documents.map {|d| d.canonical }}
      end
    end
  end

  def internal_search
    perform_search
    respond_to do |format|
      format.json do
        render :json => {'query' => @query, 'documents' => @documents}
      end
    end
  end


  private

  def perform_search
    opts        = {}
    opts        = {:account => current_account, :organization => current_organization} if logged_in?
    @query      = DC::Search::Parser.new.parse(params[:query_string])
    @query.page = params[:page] ? params[:page].to_i - 1 : 0
    @documents  = Document.search(@query, opts)
  end

end