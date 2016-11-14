require File.join(__dir__, '..', 'test_helper')

class SearchControllerTest < ActionController::TestCase

  let(:louis_documents) { Document.accessible(accounts(:louis), organizations(:tribune)) }

  def test_documents
    login_account!
    get :documents, :format=>:json, :per_page=>10, :order=>'score', :mentions=>3, :q=>''
    assert_response :success
    assert_equal louis_documents.pluck(:id).sort, json_body['documents'].map{|d|d['id']}.sort
  end

  def test_solr_searching
    login_account!
    get :documents, :format=>:json, :q=>'ponies'
  end

end
