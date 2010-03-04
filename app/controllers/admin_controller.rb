class AdminController < ApplicationController
  layout 'workspace'

  before_filter :admin_required

  def test_exception_notifier
    1 / 0
  end

end