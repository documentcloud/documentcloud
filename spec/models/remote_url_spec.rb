require 'rails_helper'

RSpec.describe RemoteUrl, type: :model do
  
  let(:document) { FactoryGirl.create(:document) }
  let(:document1) { FactoryGirl.create(:document, title: 'Foo Title') }
  
  #let(:remote_url) { FactoryGirl.create(:remote_url, document: document, 
                                         # url: 'https://devcloud.org/my/example/') }

  let(:doc_ids) do
    [document.id] # check whether its an array or hash that is being passed
  end
  
  
  # stub_request(:post, "http://localhost:8982/solr/collection1/update?wt=ruby").
  #   with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><add><doc><field name=\"id\">Document 368941150</field><field name=\"type\">Document</field><field name=\"type\">ActiveRecord::Base</field><field name=\"class_name\">Document</field><field name=\"title_s\">TV Manual</field><field name=\"language_s\">eng</field><field name=\"created_at_d\">2016-01-27T17:36:59Z</field><field name=\"published_b\">true</field><field name=\"id_i\">368941150</field><field name=\"account_id_i\">380424414</field><field name=\"organization_id_i\">761928190</field><field name=\"access_i\">4</field><field name=\"page_count_i\">68</field><field name=\"hit_count_i\">1001</field><field name=\"public_note_count_i\">102</field><field name=\"title_text\">TV Manual</field><field name=\"description_text\">I forgot to add a description</field><field name=\"full_text_text\"/></doc></add>",
  #        :headers => {'Content-Type'=>'text/xml'}).
  #   to_return(:status => 200, :body => "", :headers => {})
  
  describe 'self.populate_detected_document_ids(doc_ids)' do
    it 'saves the detected_remote_url' do
      #binding.pry
      RemoteUrl.record_hits_on_document(document.id, 'http://example.com/my_precious', 1)
      RemoteUrl.populate_detected_document_ids(doc_ids)
      expect(document.detected_remote_url).to be('http://example.com/my_precious')
    end
  end

# ### Spec Planning Below

# First get it working for one document, then add several docs

# # 1) Factory (can be used across multiple tests), create a couple of sample test documents
# Document
# => Document(id: integer, organization_id: integer, account_id: integer, 
#             access: integer, page_count: integer, title: string, slug: string, 
#             source: string, language: string, description: text, calais_id: string, 
#             publication_date: date, created_at: datetime, updated_at: datetime, 
#             related_article: text, detected_remote_url: text, remote_url: text, 
#             publish_at: datetime, text_changed: boolean, hit_count: integer, 
#             public_note_count: integer, reviewer_count: integer, 
#             file_size: integer, char_count: integer, original_extension: string, 
#             file_hash: text)

# # 2) Factories with several variations, eg. different urls
# => RemoteUrl(id: integer, document_id: integer, url: string, hits: integer, 
#              date_recorded: date, created_at: datetime, updated_at: datetime, 
#              note_id: integer, search_query: string, page_number: integer)

# => #<DC::Embed::Note::Config:0x007fdf9ced4cd8 @container=nil, @maxheight=nil, @maxwidth=nil>

# # 3) For this scope ensure the RemoteUrl factory has some hits
# scope :aggregated, -> {
#     select( 'sum(hits) AS hits, document_id, url' )
#     .group( 'document_id, url' )
#   }

# # 4) For this spec, pass docs_ids and get 
# # first context assume DOCUMENT_CLOUD_URL =~ url.url
# # second context assume  is not a DC URL

# # expectation that for any Documents 
# def self.populate_detected_document_ids(doc_ids)
#     urls = self.aggregated.where({:document_id => doc_ids})
#     top  = urls.inject({}) do |memo, url|
#       if DOCUMENT_CLOUD_URL =~ url.url
#         memo
#       else
#         id = url.document_id
#         memo[id] = url if !memo[id] || memo[id].hits < url.hits
#         memo
#       end
#     end

#     Document.where(:id=>top.keys).find_in_batches do | documents |
#       documents.each do | doc |
#         doc.detected_remote_url = top[doc.id].url
#         doc.save if doc.changed?  # see Document callbacks and stub anything that is not pertaining to the test
#       end
#     end
#  end


  end
