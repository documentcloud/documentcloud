class DocumentsController < ApplicationController
  layout nil
  
  def show
    doc = current_document(true)
    respond_to do |format|
      format.pdf  { send_file(doc.pdf_path, :disposition => 'inline', :type => 'application/pdf') }
      format.text { render :text => doc.full_text }
      format.html
    end
  end

  def destroy
    current_document.destroy
    json nil
  end
  
  def metadata
    meta = []
    if params[:ids]
      docs = params[:ids].map {|id| Document.new(:id => id) }
      meta = DC::Store::MetadataStore.new.find_by_documents(docs)
    end
    json({'metadata' => meta})
  end
    
  def thumbnail
    doc = current_document(true)
    send_file(doc.thumbnail_path, :disposition => 'inline', :type => 'image/jpeg')
  end
  
  def test
    json({'documents' => Array.new(10).map { Document.generate_fake_entry }})
  end
  
  
  private
  
  def current_document(exists=false)
    @current_document ||= exists ? DC::Store::EntryStore.new.find(params[:id]) : 
                                   Document.new(:id => params[:id])
  end
  
end 