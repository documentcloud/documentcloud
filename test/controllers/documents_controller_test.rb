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

  test "update" do
    login_account!
    put :update, :id=>doc.id, :title=>'A new Title'
    assert_response :success
    assert_equal 'A new Title', doc.reload.title
    Document.populate_annotation_counts(louis, [doc])
    assert_equal ActiveSupport::JSON.decode( doc.to_json ), json_body
  end

  test "destroy" do
    login_account!
    assert_difference( 'Document.count', -1 ){
      delete :destroy, :id=>doc.id
    }
    assert_response :success
    assert_empty Document.where( id: doc.id )
  end

  test "redact_pages" do
    login_account!
    post :redact_pages, :id=>doc.id, :redactions=>'[{"location":"286,614,353,437","page":1}]', :color=>'black'
    assert_response :success
    assert_job_action 'redact_pages'
  end

  test "remove_pages" do
    login_account!
    post :remove_pages, :id=>doc.id, :pages=>[1,2]
    assert_response :success
    assert_job_action 'document_remove_pages'
  end

  test "reorder_pages" do
    login_account!
    post :reorder_pages, :id=>doc.id, :page_order=> (0...doc.page_count).to_a.shuffle
    assert_response :success
    assert_job_action 'document_reorder_pages'
  end

  test "upload_insert_document" do
    login_account!
    post :upload_insert_document, :id=>doc.id
    assert_response 409
    post :upload_insert_document, :id=>doc.id, :file=>'none', :replace_pages_start=>1, :document_number=>1, :document_count=>1
    assert_response :success
    assert_job_action 'document_remove_pages'
  end

  test "save_page_text" do
    login_account!
    post :save_page_text, :id=>doc.id, :modified_pages=>'{"1":"new page text"}'
    assert_response :success
    assert_equal 'new page text', doc.reload.pages.where(:page_number=>1).first.text
    assert_job_action 'reindex_document'
  end

  test "loader" do
    get :loader
    assert_response :success
    assert_equal 'js', response.content_type
  end

  test "entities" do
    login_account!
    get :entities, :ids=>[doc.id]
    assert_equal entities(:person).as_json, json_body['entities'].first
  end

  test "entity" do
    login_account!
    get :entity, :entity_id=>entities(:person).id
    assert_response :success
    assert_equal entities(:person).as_json( :include_excerpts => true ), json_body['entities'].first
  end

  test "dates" do
    login_account!
    ed = entity_dates(:jan1)
    get :dates, :id=>ed.id
    json = ed.as_json
    json['date'] = ed.date.strftime('%Y-%m-%d')
    assert_response :success
    assert_equal json, json_body['date']
  end

  test "occurrence" do
    login_account!
    skip("Incorrect arguments to creating Occurrence.new  ")
    # get :occurrence, :id=>entities(:person).id, :occurrence=>'Rogers'
    # assert_response :success
  end

  test "mentions" do
    login_account!
    get :mentions, :id=>doc.id, :q=>'Ishmael'
    assert_response :success
    assert_equal "Call me <b>Ishmael</b>.", json_body['mentions'].first['text']
  end

  test "status" do
    login_account!
    get :status, :ids=>[doc.id]
    assert_response :success
    Document.populate_annotation_counts(louis,[doc])
    assert_equal doc.access, json_body['documents'].first['access']
  end


  test "per_page_note_counts" do
    login_account!
    get :per_page_note_counts, :id=>doc.id
    assert_response :success
    assert_equal( { "2"=>1, "1"=>1 }, json_body )
  end

  test "queue_length" do
    login_account!
    get :queue_length
    assert_equal 0, json_body['queue_length']
    doc.update_attributes :access=>Document::PENDING
    get :queue_length
    assert_equal 1, json_body['queue_length']
  end

  test "reprocess_text" do
    login_account!
    get :reprocess_text, :id=>doc.id
    assert_response :success
    assert_job_action 'large_document_import'
  end

  test "send_pdf" do
    get :send_pdf, :id=>doc.id
    assert_redirected_to doc.pdf_url(:direct)
  end

  test "send_page_image" do
    get :send_page_image, :id=>doc.id, :page_name=>'one-p1-800'
    assert_redirected_to pages(:first).authorized_image_url(800)
  end


  test "send_full_text" do
    get :send_full_text, :id=>doc.id
    assert_redirected_to doc.full_text_url(:direct)
  end

end
