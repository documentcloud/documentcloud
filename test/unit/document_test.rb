require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  context "A Document" do

    should_have_one :full_text
    should_have_many :pages
    should_have_many :entities

    should "" do

    end

  end

end