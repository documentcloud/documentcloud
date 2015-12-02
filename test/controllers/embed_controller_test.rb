require 'test_helper'

class EmbedControllerTest < ActionController::TestCase

  def test_document_loader
    get '/documents/loader.js'
    assert_response :success
    # TODO: Assert result matches template
  end

  def test_search_loader
    get '/embed/loader.js'
    assert_response :success
    # TODO: Assert result matches template
  end

  def test_note_loader
    get '/notes/loader.js'
    assert_response :success
    # TODO: Assert result matches template
  end

  def test_enhancer
    get 'embed/loader/enhance.js'
    assert_response :success
    # TODO: Assert result matches template
  end

  def test_unrecognized_loader_object
    get '/foo/loader.js'
    assert_response 404
  end

  def test_unimplemented_loader_format
    get 'documents/loader.html'
    assert_response 501
  end

  def test_unimplemented_enhancer_format
    get 'embed/loader/enhance.html'
    assert_response 501
  end

end
