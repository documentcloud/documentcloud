class DocumentsController < ApplicationController
  
  def test
    render :json => {
      'documents' => Array.new(10).map { Document.generate_fake_entry }
    }
  end
  
end