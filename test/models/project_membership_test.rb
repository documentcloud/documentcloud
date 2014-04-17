require 'test_helper'

class ProjectMembershipTest < ActiveSupport::TestCase

  subject { project_memberships(:collab_manual) }

  it "has associations and they query successfully" do
    assert_associations_queryable subject
  end

  it "validates document is unique" do
    project = ProjectMembership.new({
        :project=>projects(:collab),
        :document=>doc
      })
    refute project.save
    assert project.errors[:document]
  end

end
