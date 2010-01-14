# The public DocumentCloud API.
class ApiController < ApplicationController
  include DC::Search::Controller

  layout 'workspace'

  before_filter :bouncer unless Rails.env.development?

  def index

  end

  def signup
    return render unless request.post?
  end

  def search
    perform_search
    respond_to do |format|
      format.json do
        render :json => {'documents' => @documents.map {|d| d.canonical }}
      end
    end
  end

end