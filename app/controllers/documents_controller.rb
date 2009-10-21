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
  
  def metadata
    meta = []
    if params[:ids]
      docs = params[:ids].map {|id| Document.new(:id => id) }
      meta = DC::Store::MetadataStore.new.find_by_documents(docs)
    end
    json 'metadata' => meta
  end
    
  def thumbnail
    doc = current_document(true)
    send_file(doc.thumbnail, :disposition => 'inline', :type => 'image/jpeg')
  end

  
  private
  
  def send_pdf
    return redirect_to("/documents/#{@current_document.id}.txt") if @current_document.pdf.blank?
    send_file @current_document.pdf, :disposition => 'inline', :type => 'application/pdf'
  end
  
  def send_text
    render :text => @current_document.full_text
  end
  
  # TODO: Access control this document -- but not yet.
  def current_document(exists=false)
    @current_document ||= exists ? Document.find(params[:id]) : 
                                   Document.new(:id => params[:id])
  end
  
end 