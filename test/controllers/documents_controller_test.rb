require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase

  test "routing" do
    assert_recognizes(
      { controller: 'documents', id:'1', action: 'send_pdf', slug:'a_simple_image_named' },
      { path: '/documents/1/a_simple_image_named.pdf',  method: :get } )
    assert_recognizes(
      { controller: 'documents', id:'1', action: 'send_full_text', slug:'a_simple_image_named' },
      { path: '/documents/1/a_simple_image_named.txt',  method: :get } )
    assert_recognizes(
      { controller: 'documents', id:'1', page_name: 'a_simple_image_named', action: 'send_page_text' },
      { path: '/documents/1/pages/a_simple_image_named.txt',  method: :get } )
    assert_recognizes(
      { controller: 'documents', id:'1', page_name: 'a_simple_image_named', action: 'set_page_text' },
      { path: '/documents/1/pages/a_simple_image_named.txt',  method: :post } )
    assert_recognizes(
      { controller: 'documents', id:'1', page_name: 'a_simple_image_named', action: 'send_page_image' },
      { path: '/documents/1/pages/a_simple_image_named.gif',  method: :get } )
  end


  test "it can log in a reviewer" do
    reviewer = accounts(:freelancer_bob)
    reviewer.ensure_security_key!
    get :show, :id=>doc.id, :format=>:html, :key=>reviewer.security_key.key
    assert_response :success
    assert_equal reviewer.id, session['account_id']
  end

  test "it renders a public document" do
    get :show, :id=>doc.id, :format=>:html
    assert_response :success
    refute assigns[:edits_enabled]

    login_account!
    get :show, :id=>doc.id, :format=>:html
    assert assigns[:edits_enabled]
  end

  test "it renders a private document to owner" do
    get :show, :id=>secret_doc.id, :format=>:html
    assert_response :forbidden

    login_account!
    get :show, :id=>secret_doc.id, :format=>:html
    assert assigns[:edits_enabled]
    assert_response :success
  end


end
