require 'test_helper'

class RedirectControllerTest < ActionController::TestCase

  def test_without_url
    get :index
    assert_redirected_to '/'
  end

  def test_with_url
    get :index,:url=>'/foo'
    assert_redirected_to '/foo'
    assert_response 301
  end

end
