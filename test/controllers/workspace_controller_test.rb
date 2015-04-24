require_relative '../test_helper'

class WorkspaceControllerTest < ActionController::TestCase

  test "requires login" do
    get :index
    assert_redirected_to '/home'
  end

  test "has proper routes" do
    assert_recognizes({ controller: 'workspace', action: 'index' }, '/')
    assert_recognizes({ controller: 'workspace', action: 'index' }, '/results')
    assert_recognizes({ controller: 'workspace', action: 'index' }, '/search')
    assert_recognizes({ controller: 'workspace', action: 'index', query:'testquery' }, '/search/testquery')
    assert_recognizes({ controller: 'workspace', action: 'help' }, '/help')
    assert_recognizes({ controller: 'workspace', action: 'help', page: 'about' }, '/help/about')
  end

  test "renders index" do
    login_account!
    get :index
    assert_response :success
    assert assigns(:has_documents)
    assert_equal assigns(:organizations), Organization.all_slugs
  end


  test "has proper html for workspace" do
    login_account!
    get :index
    assert_select 'body.workspace.logged_in'
    assert_select 'div#content'
    # For future improvement: Parse the JavaScript out and test test
  end

  test "renders help" do
    get :help
    assert_response :success
  end

end
