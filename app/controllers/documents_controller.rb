class DocumentsController < ApplicationController
  
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
  
  def full_text
    render :text => current_document.full_text
  end
  
  def pdf
    doc = current_document(true)
    send_file(doc.pdf_path, :disposition => 'inline', :type => 'application/pdf')
  end
  
  def thumbnail
    doc = current_document(true)
    send_file(doc.thumbnail_path, :disposition => 'inline', :type => 'image/jpeg')
  end
  
  def display
    doc = current_document(true)
    doc.pdf_path ?
      redirect_to("/documents/pdf/#{doc.id}.pdf") :
      redirect_to("/documents/full_text/#{doc.id}.txt")
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