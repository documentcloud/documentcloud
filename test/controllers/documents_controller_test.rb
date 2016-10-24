require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase

  def test_routing
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


  def test_it_can_log_in_a_reviewer
    reviewer = accounts(:freelancer_bob)
    reviewer.ensure_security_key!
    get :show, :id=>doc.id, :format=>:html, :key=>reviewer.security_key.key
    assert_response :success
    assert_equal reviewer.id, session['account_id']
  end

  def test_it_renders_a_public_document
    get :show, :id=>doc.id, :format=>:html
    assert_response :success
    refute assigns[:edits_enabled]

    login_account!
    get :show, :id=>doc.id, :format=>:html
    assert assigns[:edits_enabled]
  end

  def test_it_renders_a_private_document_to_owner
    get :show, :id=>secret_doc.id, :format=>:html
    assert_response :forbidden

    login_account!
    get :show, :id=>secret_doc.id, :format=>:html
    assert assigns[:edits_enabled]
    assert_response :success
  end

  def test_update
    login_account!
    put :update, :id=>doc.id, :title=>'A new Title'
    assert_response :success
    assert_equal 'A new Title', doc.reload.title
    Document.populate_annotation_counts(louis, [doc])
    assert_equal ActiveSupport::JSON.decode( doc.to_json ), json_body
  end

  def test_destroy
    login_account!
    assert_difference( 'Document.count', -1 ){
      delete :destroy, :id=>doc.id
    }
    assert_response :success
    assert_empty Document.where( id: doc.id )
  end

  def test_redact_pages
    login_account!
    post :redact_pages, :id=>doc.id, :redactions=>'[{"location":"286,614,353,437","page":1}]', :color=>'black'
    assert_response :success
    assert_job_action 'redact_pages'
  end

  def test_remove_pages
    login_account!
    post :remove_pages, :id=>doc.id, :pages=>[1,2]
    assert_response :success
    assert_job_action 'document_remove_pages'
  end

  def test_reorder_pages
    login_account!
    post :reorder_pages, :id=>doc.id, :page_order=> (0...doc.page_count).to_a.shuffle
    assert_response :success
    assert_job_action 'document_reorder_pages'
  end

  def test_upload_insert_document
    login_account!
    post :upload_insert_document, :id=>doc.id
    assert_response 409
    post :upload_insert_document, :id=>doc.id, :file=>'none', :replace_pages_start=>1, :document_number=>1, :document_count=>1
    assert_response :success
    assert_job_action 'document_remove_pages'
  end

  def test_save_page_text
    login_account!
    post :save_page_text, :id=>doc.id, :modified_pages=>'{"1":"new page text"}'
    assert_response :success
    assert_equal 'new page text', doc.reload.pages.where(:page_number=>1).first.text
    assert_job_action 'reindex_document'
  end

  def test_entities
    login_account!
    get :entities, :ids=>[doc.id]
    assert_equal entities(:person).as_json, json_body['entities'].first

  end

  def test_entity
    login_account!
    get :entity, :entity_id=>entities(:person).id
    assert_response :success
    assert_equal entities(:person).as_json( :include_excerpts => true ).with_indifferent_access, json_body['entities'].first
  end

  def test_dates
    login_account!
    ed = entity_dates(:jan1)
    get :dates, :id=>ed.id
    json = ed.as_json(:include_excerpts=>true)
    assert_response :success
    assert_equal json.with_indifferent_access, json_body['date']
  end

  def test_retrieving_occurrence
    login_account!
    get :occurrence, :id=>entities(:person).id, :occurrence=>'8:16'
    assert_response :success
    ex = json_body['excerpts']
    assert_equal 1, ex.length
    assert_equal "Call me <span class=\"occurrence\">Ishmael.</span>", ex.first['excerpt']
    assert_equal 1, ex.first['page_number']
  end

  def test_mentions
    login_account!
    get :mentions, :id=>doc.id, :q=>'Ishmael'
    assert_response :success
    assert_equal "Call me <b>Ishmael</b>.", json_body['mentions'].first['text']
  end

  def test_status
    login_account!
    get :status, :ids=>[doc.id]
    assert_response :success
    Document.populate_annotation_counts(louis,[doc])
    assert_equal doc.access, json_body['documents'].first['access']
  end


  def test_per_page_note_counts
    login_account!
    get :per_page_note_counts, :id=>doc.id
    assert_response :success
    assert_equal( { "2"=>1, "1"=>1 }, json_body )
  end

  def test_queue_length
    login_account!
    get :queue_length
    assert_equal 0, json_body['queue_length']
    doc.update_attributes :access=>Document::PENDING
    get :queue_length
    assert_equal 1, json_body['queue_length']
  end

  def test_reprocess_text
    login_account!
    get :reprocess_text, :id=>doc.id
    assert_response :success
    assert_job_action 'large_document_import'
  end

  def test_send_pdf
    get :send_pdf, :id=>doc.id
    assert_redirected_to doc.pdf_url(direct: true)
  end

  def test_send_page_image
    get :send_page_image, :id=>doc.id, :page_name=>'one-p1-800'
    assert_match doc.page_image_path(1, 800), response.headers['Location']
  end

  def test_send_full_text
    get :send_full_text, :id=>doc.id
    assert_match doc.full_text_path, response.headers['Location']
  end

  def test_send_page_text
    # n.b. the document's title might have /-p\d/ naturally occuring
    # We should get the page that corresponds to the last occurance
    get :send_page_text, :id=>doc.id, :page_name=>'one-p88-p1-800'
    assert_response :success
    assert_equal pages(:first).text, response.body
  end

  def test_set_page_text
    login_account!
    post :set_page_text, :id=>doc.id, :page_name=>'one-p1-800', :text=>'This is my page!'
    assert_equal "This is my page!", pages(:first).text
  end

  def test_preview
    login_account!
    get :preview, :id=>doc.id
    assert_response :success
    assert_template "preview"
  end

end
