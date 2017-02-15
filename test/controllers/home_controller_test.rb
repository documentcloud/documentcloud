require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:document)
  end

  def test_opensource
    get :opensource
    yaml = YAML.load_file("#{Rails.root}/app/views/home/opensource.yml")
    assert_equal yaml['news'], assigns(:news)
    assert_equal yaml['github'], assigns(:github)
  end

  def test_contributors
    get :contributors
    yaml = YAML.load_file("#{Rails.root}/app/views/home/contributors.yml")
    assert_equal yaml['contributors'], assigns(:contributors)
  end
end
