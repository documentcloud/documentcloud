require 'test_helper'

class ImportControllerTest < ActionController::TestCase

  def test_upload_document
    get :upload_document
    assert_response 403

    login_account!
    assert_difference 'Document.count' do
      get :upload_document, :url=>'http://test.com/file.pdf', :file=>'on', :title=>"Test Doc"
    end
    assert_response :success
    assert_job_action 'document_import'
  end

  def test_cloud_crowd_success
    ProcessingJob.create!( :document=>doc, :account=>louis, :cloud_crowd_id => 42, :title=>'import', :remote_job => 'document_import' )
    assert_difference( ->{ ProcessingJob.incomplete.count }, -1 ) do
      get :cloud_crowd, :job=>'{ "id": 42, "status":"succeeded" }'
    end
  end

  def test_cloud_crowd_failure
    ProcessingJob.create!( :document=>doc, :account=>louis, :cloud_crowd_id => 42,
      :title=>'import', :remote_job => 'document_import' )
    assert_difference( ->{ ProcessingJob.incomplete.count }, -1 ) do
      get :cloud_crowd, :job=>'{ "id": 42, "status":"failed" }'
    end
    assert_equal Document::ERROR, doc.reload.access
  end

  def test_update_access
    get :update_access, {:job=>{'id'=>1234}.to_json}
    assert_response 201
  end

end
