class StaticController < ApplicationController

  before_filter :bouncer if Rails.env.staging?

  def home
    @posts = date_sorted(yaml_for('home'))
  end

  def about
  end

  def contact
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

  def tos
  end

  def news
    @news = date_sorted(yaml_for('news'))
  end


  private

  def date_sorted(list)
    list.sort_by {|item| item.last }.reverse
  end

  def yaml_for(action)
    YAML.load_file("#{Rails.root}/app/views/static/#{action}.yml")
  end

end
