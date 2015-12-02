class EmbedController < ApplicationController
  layout false

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
