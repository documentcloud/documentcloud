require 'test_helper'

class PublicControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
    assert_nil assigns(:current_account)
    assert_not_nil assigns(:include_analytics)
    assert_template 'workspace/index'
  end

end
