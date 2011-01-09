class HomeController < ApplicationController

  include DC::Access

  def index
    @document = Document.random(:conditions => {:access => PUBLIC}, :limit => 1).first
  end

end