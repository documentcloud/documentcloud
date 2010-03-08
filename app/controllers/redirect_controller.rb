# Handle 301 redirects for pages that have changed location.
class RedirectController < ApplicationController

  def index
    return redirect_to(params[:url], :status => 301) if params[:url]
    redirect_to '/'
  end

end