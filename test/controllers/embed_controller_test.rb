require 'test_helper'

class EmbedControllerTest < ActionController::TestCase

  test "should render embed enhancer" do
    get :enhance, format: 'js'
    assert_response :success
    assert_template 'embed/enhance'
  end

  test "should render document embed loader" do
    get :loader, object: :viewer, format: 'js'
    assert_response :success
    assert_template 'documents/embed_loader'
  end

  test "should render note embed loader" do
    get :loader, object: :notes, format: 'js'
    assert_response :success
    assert_template 'annotations/embed_loader'
  end

  test "should render search embed loader" do
    get :loader, object: :embed, format: 'js'
    assert_response :success
    assert_template 'search/embed_loader'
  end

  test "shouldn't find unrecognized embed type loader" do
    get :loader, object: :foo, format: 'js'
    assert_response 404
  end

  test "shouldn't implement unrecognized embed loader format" do
    get :loader, object: :documents, format: 'html'
    assert_response 501
  end

  test "shouldn't implement unrecognized embed enhancer format" do
    get :enhance, format: 'html'
    assert_response 501
  end

end
