class DocumentsController < ApplicationController
  
  def metadata
    meta = []
    if params[:ids]
      docs = params[:ids].map {|id| Document.new(:id => id) }
      meta = DC::Store::MetadataStore.new.find_by_documents(docs)
    end
    render :json => {'metadata' => meta}
  end
  
  def full_text
    get_document
    render :text => @document.full_text
  end
  
  def pdf
    get_document(true)
    send_file(@document.pdf_path, :disposition => 'inline', :type => 'application/pdf')
  end
  
  def thumbnail
    get_document(true)
    send_file(@document.thumbnail_path, :disposition => 'inline', :type => 'image/jpeg')
  end
  
  def display
    get_document(true)
    @document.pdf_path ?
      redirect_to("/documents/pdf/#{@document.id}.pdf") :
      redirect_to("/documents/full_text/#{@document.id}.txt")
  end
  
  def test
    render :json => {
      'documents' => Array.new(10).map { Document.generate_fake_entry }
    }
  end
  
  
  private
  
  def get_document(from_entry=false)
    if from_entry
      @document ||= DC::Store::EntryStore.new.find(params[:id])
    else
      @document ||= Document.new(:id => params[:id])
    end
  end
  
end 