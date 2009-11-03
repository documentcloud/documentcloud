class SearchController < ApplicationController
  layout 'empty'
  
  before_filter :bouncer unless Rails.development?
  
  def search
    respond_to do |format|
      format.html
      format.json do
        opts        = {}
        opts        = {:account => current_account, :organization => current_organization} if logged_in?
        query       = DC::Search::Parser.new.parse(params[:query_string])
        query.page  = params[:page] ? params[:page].to_i - 1 : 0
        docs        = Document.search(query, opts)
        render :json => { 'query' => query, 'documents' => docs }
      end
    end
  end
  
end