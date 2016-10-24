require 'test_helper'

class ImportControllerTest < ActionController::TestCase

  it "uploads a document if logged in" do
    get :upload_document
    assert_response :forbidden

    login_account!
    assert_difference 'Document.count' do
      get :upload_document, { url: 'http://test.com/file.pdf', file: 'on',
                              title: "Test Doc" }
    end
    assert_response :success
    assert_job_action 'document_import'
  end

  # TODO: Fix this test! (I don't know how.)
  it "cloud crowd success" do
    ProcessingJob.create!(document: doc, account: louis, cloud_crowd_id: 42,
      title: 'import', remote_job: 'document_import')
    assert_difference(-> { ProcessingJob.incomplete.count }, -1) do
      get :cloud_crowd, {job: {id: 42, status: 'succeeded'}.to_json}
    end
  end

  # TODO: Fix this test! (I don't know how.)
  it "cloud crowd failure" do
    ProcessingJob.create!(document: doc, account: louis, cloud_crowd_id: 42,
      title: 'import', remote_job: 'document_import')
    assert_difference( ->{ ProcessingJob.incomplete.count }, -1 ) do
      get :cloud_crowd, {job: {id: 42, status: 'failed'}.to_json}
    end
    assert_equal Document::ERROR, doc.reload.access
  end

  # TODO: Fix this test! (Need to pass a working secret to the second `get`)
  it "allows updating access with a secret" do
    get :update_access, {job: {id: 1234}.to_json}
    assert_response :forbidden

    get :update_access, {job: {id: 1234}.to_json, secret: 'foobar'}
    assert_response :created
  end

end
