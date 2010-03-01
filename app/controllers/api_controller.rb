# The public DocumentCloud API.
class ApiController < ApplicationController
  include DC::Search::Controller

  layout 'workspace'

  before_filter :bouncer if Rails.env.staging?

  def index

  end

  def signup
    return render unless request.post?
  end

  def search
    options = {
      :show_entities => !!params[:entities]
    }
    perform_search
    respond_to do |format|
      format.json do
        render :json => {'documents' => @documents.map {|d| d.canonical(options) }}
      end
    end
  end

end