class EmbedController < ApplicationController
  layout false

  # In development/test only, let us directly access the embed loaders.
  # In real life, these are only accessed from the CDN root.
  before_action { not_found } unless Rails.env.development? || Rails.env.test?

  def enhance
    return not_implemented unless request.format.js?

    render :enhance, :content_type => Mime::Type.lookup_by_extension('js')
  end

  def loader
    return not_implemented unless request.format.js?

    object_controller_map = {
      'documents' => 'documents',
      'notes'     => 'annotations',
      'embed'     => 'search'
    }

    if matching_controller = object_controller_map[params[:object]]
      render "#{matching_controller}/embed_loader",
             :content_type => Mime::Type.lookup_by_extension('js')
    else
      return not_found
    end
  end

end
