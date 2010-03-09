class AdminController < ApplicationController
  layout nil

  before_filter :admin_required

  def test_exception_notifier
    1 / 0
  end

  def test_embedded_viewer

  end

end