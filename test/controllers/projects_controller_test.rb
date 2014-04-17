require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  def setup
    login_account!
  end

  def test_index
    get :index
    assert_equal louis.projects.first.as_json.stringify_keys, json_body.first
  end

  def test_create
    assert_difference 'Project.count' do
      post :create, :title=>"New Project", :description=>"meh", :document_ids=>[secret_doc.id]
    end
  end

  def test_update
    project = projects(:collab)
    put :update, :title=>'rutabagas', :id=>project.id
    assert_equal 'rutabagas', project.reload.title
  end

  def test_destroy
    assert_difference( 'Project.count', -1 ) do
      delete :destroy, :id=>projects(:collab)
    end
  end

  def test_documents
    get :documents, :id=>projects(:collab)
    assert_equal projects(:collab).document_ids, json_body.map{ |json| json['id'] }
  end

  def test_add_documents
    project = projects(:collab)
    assert_difference 'project.documents.count' do
      put :add_documents, :id=>project, :document_ids=>[secret_doc.id]
    end
  end

  def test_remove_documents
    project = projects(:collab)
    assert_difference( 'project.documents.count', -1 ) do
      put :remove_documents, :id=>project, :document_ids=>[doc.id]
    end

  end
end
