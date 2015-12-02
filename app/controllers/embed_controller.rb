class EmbedController < ApplicationController
  layout false

  # In development only, let us directly access the embed loaders.
  # In real life, these are only accessed from the CDN root.
  before_action { not_found } unless Rails.env.development?

  def enhance
    return not_implemented unless request.format.js?

    render :enhance, :content_type => Mime::Type.lookup_by_extension('js')
  end

  def loader
    return not_implemented unless request.format.js?

    controller_map = {
      'documents' => 'documents',
      'notes'     => 'annotations',
      'embed'     => 'search'
    }

    render "#{controller_map[params[:object]]}/embed_loader",
           :content_type => Mime::Type.lookup_by_extension('js')
  end

end
