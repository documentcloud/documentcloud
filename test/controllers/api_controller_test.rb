require 'test_helper'

class ApiControllerTest < ActionController::TestCase

  let(:read_only?) { Rails.application.config.read_only }

  it "responds to read-only mode" do
    get :documents, :id => doc.id, :format => :json
    assert_response 200
    get :update, :id => doc.id, :format => :json
    assert_response read_only? ? 503 : 401
  end

  it "test_routing" do
    assert_recognizes(
      { controller: 'api', action: 'cors_options', :format=>'json', "allowed_methods"=>[:get] },
      { path: '/api/documents/pending.json',  method: :options } )
    assert_recognizes(
      { controller: 'api', action: 'cors_options', id:"2", :format=>'json', "allowed_methods"=>[:get, :put, :delete ] },
      { path: '/api/documents/2.json',  method: :options } )
    assert_recognizes(
      { controller: 'api', action: 'cors_options', id:"2", :format=>'json', "allowed_methods"=>[:get] },
      { path: '/api/documents/2/entities.json',  method: :options } )
    assert_recognizes(
      { controller: 'api', action: 'cors_options', id:"2", note_id:'3', :format=>'json', "allowed_methods"=>[:get] },
      { path: '/api/documents/2/note/3.json',  method: :options } )
    assert_recognizes(
      { controller: 'api', action: 'cors_options', id:"2", note_id:'3', :format=>'json', "allowed_methods"=>[:get] },
      { path: '/api/documents/2/notes/3.json',  method: :options } )
    assert_recognizes(
      { controller: 'api', action: 'cors_options', id:"2", :format=>'json', "allowed_methods"=>[:get,:put,:delete] },
      { path: '/api/projects/2.json',  method: :options } )
    assert_recognizes(
      { controller: 'api', action: 'cors_options', :format=>'json', "allowed_methods"=>[:get,:post] },
      { path: '/api/projects.json',  method: :options } )
    assert_recognizes(
      { controller: 'api', action: 'cors_options', :format=>'json', "allowed_methods"=>[:get] },
      { path: '/api/search.json',  method: :options } )
  end

  it "test_index" do
    get :index
    assert_redirected_to '/help/api'
  end

  it "test_it_sets_cors_options" do
    get :cors_options
    assert_response 400
    get :cors_options, :allowed_methods=>['GET']
    assert_response :success
    refute response.headers['Access-Control-Allow-Origin'], "Access Control was set, when request didn't require it"
    @request.headers['Origin'] = 'test.test.com'
    get :cors_options, { :allowed_methods=>['GET'] }
    %w{ OPTIONS GET POST PUT DELETE }.each do | method |
      assert_includes cors_allowed_methods, method
    end
    assert_equal ["Accept", "Authorization", "Content-Length", "Content-Type", "Cookie"], cors_allowed_headers.sort
  end

  it "test_empty_search_results" do
    get :search, q: 'ponies', :format => :json
    assert_equal 0, json_body['total']
  end

  it "test_search" do
    get :search, q: "document:#{doc.id}", :format=>:json
    assert_equal 1, json_body['total']
    assert_equal doc.canonical_id, json_body['documents'].first['id']
  end

  it "test_api_login_required_returns_unauthorized" do
    get :upload
    assert_response read_only? ? 503 : 401
  end

  it "test_search_works_if_authenticated" do
    # authentication is optional, but it can get you more docs
    account = accounts(:louis)
    request.headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(account.email, 'password')
    get(:search, q: "document:#{doc.id}", format: :json)
    assert_response 200
    assert_equal 1, json_body['total']
    assert_equal doc.canonical_id, json_body['documents'].first['id']
  end

  it "test_search_doesnt_work_if_authentication_fails" do
    # otherwise the user might enter the wrong password and be sad the extra docs are missing
    # https://github.com/documentcloud/documentcloud/issues/89
    request.headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("WRONG-email@example.org", "WRONG-password")
    refute request.authorization.blank?
    get(:search, q: "document:#{doc.id}", format: :json)
    assert_response 403
  end

  it "test_documents" do
    login_account!
    get :documents
    assert_response :bad_request
    get :documents, :id=>1234, :format=>:json # non existant
    assert_response :not_found
    get :documents, :id=>doc.id, :format=>:json # non existant
    assert_equal doc.canonical_id, json_body['document']['id']
  end

  it "test_pending" do
    get :pending
    assert_equal 0, json_body['total_documents']
    assert_nil json_body['your_documents']
    Document.update_all :access => Document::PENDING
    login_account!
    get :pending
    assert_equal Document.count, json_body['total_documents']
    assert_equal louis.documents.count, json_body['your_documents']
  end

  it "test_notes" do
    note = annotations(:public)
    get :notes, :note_id=>note.id, :format=>:json
    assert_response :success
    assert_equal note.canonical, json_body['annotation']
  end

  it "test_it_doesnt_return_private_notes_unless_authorized" do
    note = annotations(:private)
    get :notes, :note_id=>note.id, :format=>:json
    assert_response :not_found

    login_account!
    get :notes, :note_id=>note.id, :format=>:json
    assert_response :success
    assert_equal note.canonical, json_body['annotation']
  end

  it "test_entities" do
    get :entities, :id=>doc.id, :format=>:json
    assert_response :success
    assert_equal doc.ordered_entity_hash.as_json, json_body['entities']
  end

  it "test_project" do
    login_account!
    project = projects(:collab)
    get :project, :id=>project.id, :format=>:json, :include_document_ids=>true
    assert_response :success
    assert_equal project.canonical(:include_document_ids=>true), json_body['project']
  end

  it "test_projects" do
    login_account!
    get :projects, :format=>:json, :include_document_ids=>true
    assert_response :success
    assert_equal [ projects(:collab).canonical(:include_document_ids=>true) ], json_body['projects']
  end

  # Tests that don't matter in read-only mode
  unless Rails.application.config.read_only

    it "test_it_requires_authentication" do
      [ :upload, :project, :projects, :update, :destroy, :create_project, :update_project, :destroy_project ].each do | action |
        get action
        assert_response 401
      end
    end

    it "test_upload" do
      login_account!
      get :upload
      assert_response 400
      get :upload, :title=>'a test', :file=>'http://test.com/file.pdf'
      assert_response 200
      assert_job_action 'document_import'
    end

    it "test_update" do
      post :update, :id=>doc.id, :format=>:json
      assert_response 401
      login_account!
      post :update, :id=>doc.id, :format=>:json, :title=>'A New Title'
      assert_response :success
      assert_equal 'A New Title', doc.reload.title
    end

    it "test_destroy" do
      login_account!
      delete :destroy, :id=>doc.id
      assert_response :success
      refute Document.where( :id=>doc.id ).first
    end

    it "test_create_projects" do
      login_account!
      put :create_project, :document_ids=>[doc.id],:title=>'new project',:description=>'no desc'
      assert_response :success
      assert_equal 'new project', json_body['project']['title']
      refute_empty doc.projects.where( :title=>'new project' )
    end

    it "test_update_project" do
      login_account!
      project = projects(:collab)
      post :update_project, :id=>project.id, :document_ids=>[secret_doc.id]
      assert_response :success
      assert_equal [secret_doc.id], project.reload.document_ids
    end

    it "test_destroy_project" do
      login_account!
      project = projects(:collab)
      delete :destroy_project, :id=>project.id
      assert_response :success
      assert_raises( ActiveRecord::RecordNotFound ){ Project.find( project.id ) }
    end

  end

end
