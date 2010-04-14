require File.dirname(__FILE__) + '/support/setup'

class VacuumAnalyze < CloudCrowd::Action

  def process
    ActiveRecord::Base.connection.execute "vacuum analyze;"
    true
  end

end