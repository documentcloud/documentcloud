require 'test_helper'

class CollaboratorsControllerTest < ActionController::TestCase

  def test_routing
    assert_recognizes(
      { controller: 'collaborators', project_id: '1', action: 'create' },
      { path: '/projects/1/collaborators',  method: :post } )
    assert_recognizes(
      { controller: 'collaborators', project_id: '1', id: '1', action: 'destroy' },
      { path: '/projects/1/collaborators/1',  method: :delete } )
  end

  def test_create
    login_account!
    project = projects(:collab)
    refute_empty project.collaborations
    post :create, :project_id=>project.id, :email=>accounts(:freelancer_bob).email
    assert_equal 2, project.collaborations.count
  end

  def test_destroy
    login_account!
    project = projects(:collab)
    user = accounts(:freelancer_bob )
    assert project.add_collaborator( user )
    refute_empty project.collaborations
    assert_difference ->{ project.collaborations.count }, -1 do
      delete :destroy, :project_id=>project.id, :id=>user.id
    end
  end

end
