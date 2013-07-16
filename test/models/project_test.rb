require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  context "A Project" do

    should_belong_to :account

  end

end