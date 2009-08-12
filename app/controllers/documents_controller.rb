class DocumentsController < ApplicationController
  
  def metadata
    meta = []
    if params[:ids]
      docs = params[:ids].map {|id| Document.new(:id => id) }
      meta = docs.inject([]) {|memo, doc| memo += doc.metadata; memo}
    end
    render :json => {'metadata' => meta}
  end
  
  def full_text
    render :text => Document.new(:id => params[:id]).full_text
  end
  
  def test
    render :json => {
      'documents' => Array.new(10).map { Document.generate_fake_entry }
    }
  end
  
end