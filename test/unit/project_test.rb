require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  context "A Project" do

    should_belong_to :account

    should "only be able to save unique document ids" do
      project = Account.first.projects.create(:title => "l", :document_ids => '101,20,101,20')
      assert project.document_ids == '101,20'
    end

  end

end