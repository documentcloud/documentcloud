require 'rails_helper'

RSpec.describe RemoteUrl, type: :model do
  
  let(:document1) { FactoryGirl.create :document }
  let(:document2) { FactoryGirl.create :document, :random }
  let(:document3) { FactoryGirl.create :document, :random }
  
  let(:doc_ids) do
    [document1.id, document2.id, document3.id]
  end

  describe 'self.populate_detected_document_ids(doc_ids)' do
    it 'saves the detected_remote_url' do
      RemoteUrl.record_hits_on_document(document1.id, 'http://example.com/my_foo_1', 1)
      RemoteUrl.record_hits_on_document(document2.id, 'http://example.com/my_foo_2', 3)
      RemoteUrl.record_hits_on_document(document3.id, 'http://example.com/my_foo_3', 4)

      RemoteUrl.populate_detected_document_ids(doc_ids)
      document1.reload
      expect(document1.detected_remote_url).to eq('http://example.com/my_foo_1')
      document2.reload
      expect(document2.detected_remote_url).to eq('http://example.com/my_foo_2')
      document3.reload
      expect(document3.detected_remote_url).to eq('http://example.com/my_foo_3')
    end
  end
end
