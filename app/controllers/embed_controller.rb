class EmbedController < ApplicationController
  layout nil

  # In development/test only, let us directly access the embed loaders.
  # In real life, these are only accessed from the CDN root.
  before_action { not_found } unless Rails.env.development? || Rails.env.test?

  # The enhancer is designed in `documentcloud-pages`, installed via bower, 
  # built by `rake build:embed:page`, and deployed to S3, but but we provide a 
  # route to it here for development and testing.
  def enhance
    return not_implemented unless request.format.js?

    render :enhance, :content_type => js_mime_type
  end

  # The loaders live in their respective view folders and are deployed to S3,
  # but we provide routes to them here for development and testing.
  def loader
    return not_implemented unless request.format.js?

    object_controller_map = {
      'viewer'    => 'documents',
      'notes'     => 'annotations',
      'embed'     => 'search'
    }

    return not_found unless matching_controller = object_controller_map[params[:object]]

    render "#{matching_controller}/embed_loader", :content_type => js_mime_type
  end

  private
  
  def js_mime_type
    Mime::Type.lookup_by_extension('js')
  end

end
