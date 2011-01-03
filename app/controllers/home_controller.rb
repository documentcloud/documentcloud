class HomeController < ApplicationController

  include DC::Access

  def index
    @documents = Document.random :conditions => {:access => PUBLIC}, :limit => 3
  end

end