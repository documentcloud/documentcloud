class HomeController < ApplicationController

  include DC::Access

  def index
    @documents = Document.random(:conditions => {:access => PUBLIC}, :limit => 1)
  end

  def opensource
    yaml    = yaml_for('opensource')
    @news   = yaml['news']
    @github = yaml['github']
  end


  private

  def date_sorted(list)
    list.sort_by {|item| item.last }.reverse
  end

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/static/#{action}.yml")
  end

end