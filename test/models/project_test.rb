require 'test_helper'

class ProjectTest < ActiveSupport::TestCase


  subject { projects(:collab) }

  it "has associations and they query successfully" do
    assert_associations_queryable subject
  end

  it "has scopes that are queryable" do
    assert_working_relations( Project, [ :alphabetical, :visible, :hidden ] )
    assert Project.accessible( louis )
  end

  it "loads for an account" do
    assert Project.load_for( louis )
  end

  it "can set documents from ids" do
    assert subject.documents.include? doc
    refute subject.documents.include? secret_doc
    subject.set_documents( [secret_doc.id] )
    refute subject.documents.include? doc
    assert subject.documents.include? secret_doc
  end

  it "can add documents" do
    subject.add_documents( [secret_doc.id] )
    assert subject.documents.include? secret_doc
    assert subject.documents.include? doc
    subject.add_documents( [secret_doc.id] )
  end

  it "can remove documents" do
    subject.add_documents( [secret_doc.id] )
    subject.remove_documents( [ doc.id ] )
    assert subject.documents.include? secret_doc
    refute subject.documents.include? doc
  end

  it "can add collaborators" do
    refute subject.collaborations.where( :account_id=> joe ).exists?
    assert subject.add_collaborator( joe )
    assert subject.collaborations.where( :account_id=> joe ).exists?
  end

  it "can remove collaborations" do
    subject.add_collaborator( louis )
    refute subject.hidden?
    subject.remove_collaborator( louis )
    assert Project.exists?( subject.id )

    # if it's hidden, it deletes itself once the last collaborator
    # is removed
    subject.add_collaborator( louis )
    subject.update_attributes :hidden=>true
    subject.remove_collaborator( louis )
    refute Project.exists?( subject.id )
  end

  it "updates documents reviewer counts" do
    assert_equal 0, subject.document.reviewer_count
    subject.add_collaborator( louis )
    assert_equal 1, subject.collaborations.count
    # not hidden, no update performed
    assert_equal 0, subject.document.reviewer_count
    subject.update_attributes :hidden=>true
    subject.update_reviewer_counts
    assert_equal 1, subject.document.reviewer_count
  end

  it "can retrieve other collaborations" do
    subject.add_collaborator( louis )
    assert_empty subject.other_collaborators( louis )
    subject.add_collaborator( joe )
    refute_empty subject.other_collaborators( louis )
  end

  it "can add documents" do
    assert subject.documents.include? doc
    refute subject.documents.include? secret_doc
    subject.add_document( secret_doc )
    assert subject.documents.include? secret_doc
  end

  it "can collect document_ids" do
    # Project#document_ids used to be a method - removed in favor of Rails built-in xxx_ids
    assert_equal [368941146], subject.document_ids
    assert_equal ['368941146-tv'], subject.canonical_document_ids
  end

  it "collects collaborator ids" do
    # Project#collaborator_ids used to be a method - removed in favor of Rails built-in xxx_ids
    assert_equal [louis.id], subject.collaborator_ids
    subject.add_collaborator( joe )
    assert_equal [louis.id, joe.id].sort, subject.collaborator_ids.sort
  end

  it "counts annotations" do
    count = subject.annotation_count(louis)
    assert_equal subject.documents.inject(0){|sum, doc| sum += doc.annotations.accessible(louis).count }, count
  end

  it "generates canonical representation" do
    assert subject.canonical['document_ids']
    assert_equal ['id','title','description','document_ids'], subject.canonical.keys
    assert_equal ['id','title','description', 'document_count'], subject.canonical(:include_document_ids=>false).keys
  end

  it "generates json" do
    data = ActiveSupport::JSON.decode(subject.to_json(:include_collaborators=>true))
    assert data.has_key?('collaborators')
  end


end
