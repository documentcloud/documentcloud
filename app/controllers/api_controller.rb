# The public DocumentCloud API.
class ApiController < ApplicationController
  include DC::Search::Controller

  layout 'workspace'

  before_filter :bouncer if Rails.env.staging?

  before_filter :api_login_required, :only => [:upload]

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

  # Upload API, similar to our internal upload API for starters. Parameters:
  # file, title, access, source, description.
  def upload
    return bad_request unless params[:file] && params[:title] && current_account
    render :json => Document.upload(params, current_account).canonical
  end

end