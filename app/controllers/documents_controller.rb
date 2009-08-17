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
    get_document
    send_file(@document.pdf_path, :disposition => 'inline', :type => 'application/pdf')
  end
  
  def display
    get_document
    File.exists?(@document.pdf_path) ? self.pdf : self.full_text
  end
  
  def test
    render :json => {
      'documents' => Array.new(10).map { Document.generate_fake_entry }
    }
  end
  
  
  private
  
  def get_document
    @document ||= Document.new(:id => params[:id])
  end
  
end 