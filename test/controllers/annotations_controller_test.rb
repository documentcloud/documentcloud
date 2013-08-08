require 'test_helper'

class AnnotationsControllerTest < ActionController::TestCase

  it "has proper routes" do
  end

  def setup
    login_account!
  end

  it "retrieves index" do
    get :index, :document_id => doc.id
    assert_response 200
    assert_equal  doc.annotation_ids.sort, json_body.map{|note| note['id'] }.sort
  end

  it "gets a single note" do
    note = doc.annotations.first
    get :show, :id=>note.id, :document_id => doc.id, :format=>:js
    assert_response 200
    assert_match( /\"id\":#{note.id}/, @response.body )
  end

  it "print all notes" do
    get :print, :docs=>[doc.id,secret_doc.id]
    doc.annotations.each do | note |
      assert_match( /#{note.content}/, @response.body )
    end
  end


  it "can create an annotation" do
    assert_difference( 'Annotation.count', 1 ) do
      put :create, :document_id=>doc.id, :page_number=>2, :title=>'Test Note',
          :content=>'this is a note', :location=>23, :access=>Document::PUBLIC
    end
  end

  it "can update" do
    note = doc.annotations.first
    post :update, :document_id=>doc.id, :id=>note.id, :title=>'New Title',
         :content=>'I have become death the destroyer of worlds', :access=>'private'
    assert_response :success
    note.reload
    assert_equal 'New Title', note.title
    assert_equal 'I have become death the destroyer of worlds', note.content
    assert_equal Annotation::PRIVATE, note.access
  end

  it "can destroy" do
    note = doc.annotations.first
    delete :destroy, :document_id=>doc.id, :id=>note.id
    assert_raises(ActiveRecord::RecordNotFound){
      doc.annotations.find( note.id )
    }
  end

  it "sets cors options" do
    get :cors_options
    assert_response 400
    request.headers['Origin']='http://test.com/'
    get :cors_options, :allowed_methods=>['GET']
    assert_response :success
    assert_equal 'http://test.com/', response.headers['Access-Control-Allow-Origin']
    assert_equal 'OPTIONS, GET, POST, PUT, DELETE', response.headers['Access-Control-Allow-Methods']
    assert_equal 'Accept,Authorization,Content-Length,Content-Type,Cookie', response.headers['Access-Control-Allow-Headers']
  end


end
