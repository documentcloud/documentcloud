class DocumentsController < ApplicationController
  layout nil

  before_filter(:bouncer, :only => [:show]) unless Rails.env.development?

  def show
    current_document(true)
    respond_to do |format|
      format.pdf  { send_pdf }
      format.text { send_text }
      format.html
    end
  end

  def destroy
    current_document(true).destroy
    json nil
  end

  # TODO: Access-control this.
  def metadata
    json 'metadata' => Metadatum.all(:conditions => {:document_id => params[:ids]})
  end

  def thumbnail
    doc = current_document(true)
    secured_url = File.join(DC::Store::AssetStore.asset_root, doc.thumbnail_path)
    send_file(secured_url, :disposition => 'inline', :type => 'image/jpeg')
  end

  def page_text
    doc         = current_document(true)
    page_number = params[:page_name].match(/(\d+)\Z/)[1].to_i
    page        = doc.pages.find_by_page_number(page_number)
    return not_found unless page
    @response   = page.text
    return if jsonp_request?
    render :text => @response
  end

  def search
    doc          = current_document(true)
    page_numbers = doc.pages.search_text(params[:q]).map(&:page_number)
    @response    = {'query' => params[:q], 'results' => page_numbers}
    return if jsonp_request?
    render :json => @response
  end


  private

  def send_pdf
    secured_url = File.join(DC::Store::AssetStore.asset_root, @current_document.pdf_path)
    send_file secured_url, :disposition => 'inline', :type => 'application/pdf'
  end

  def send_text
    render :text => @current_document.full_text.text
  end

  def current_document(exists=false)
    @current_document ||= exists ?
      Document.accessible(current_account, current_organization).find(params[:id]) :
      Document.new(:id => params[:id])
  end

end