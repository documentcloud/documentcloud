class SprocketsController < ActionController::Base
  caches_page :show
  
  def show
    render :text => SprocketsApplication.source, :content_type => "text/javascript"
  end
end
