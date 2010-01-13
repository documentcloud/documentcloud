class StaticController < ApplicationController

  def about
  end

  def contributors
    yaml          = yaml_for('contributors')
    @partners     = yaml['partners']
    @contributors = yaml['contributors']
  end

  def opensource
    yaml    = yaml_for('opensource')
    @news   = yaml['news']
    @github = yaml['github']
  end

  def faq
  end

  def news
    @news = yaml_for('news').sort_by {|item| item.last }.reverse
  end


  private

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/static/#{action}.yml")
  end

end
