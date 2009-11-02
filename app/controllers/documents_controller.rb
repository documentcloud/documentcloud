class DocumentsController < ApplicationController
  layout nil
  
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

  
  private
  
  def send_pdf
    secured_url = File.join(DC::Store::AssetStore.asset_root, @current_document.pdf_path)
    send_file secured_url, :disposition => 'inline', :type => 'application/pdf'
  end
  
  def send_text
    render :text => @current_document.full_text.text
  end
  
  # TODO: Access control this document -- but not yet.
  def current_document(exists=false)
    @current_document ||= exists ? Document.find(params[:id]) : 
                                   Document.new(:id => params[:id])
  end
  
end 