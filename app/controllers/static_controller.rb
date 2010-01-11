class StaticController < ApplicationController

  # Get the page title from the content of the first line of the template.
  def set_title(name)
    File.open(RAILS_ROOT + "/app/views/static/#{name}.erb") do |file|
      @title = (file.readline.match />(.*)</)[1]
    end
  end


  def code
    set_title('code')
    @news = [
      [ "2009 Open Source Top Ten",
        "http://ozmm.org/posts/2009_open_source_top_ten.html",
        "Ones, Zeros, Majors and Minors",
        Date.civil(2009, 12, 17)],
      [ "Episode 0.0.5 – Document Cloud",
        "http://thechangelog.com/post/272530971/episode-0-0-5-document-cloud",
        "The Changelog",
        Date.civil(2009, 12, 6)],
      [ "Scaling Rails – On The Edge – Part 3",
        "http://blog.envylabs.com/2009/11/scaling-rails-part-3/",
        "Envy Labs",
        Date.civil(2009, 11, 25)],
      [ "Jammit: Industrial Strength Asset Packaging for Rails Apps",
        "http://www.railsinside.com/plugins/354-jammit-industrial-strength-asset-packaging-for-rails-apps.html",
        "Rails Inside",
        Date.civil(2009, 11, 17)]
    ]

    @github = [
      [ "cloud-crowd",
        "http://wiki.github.com/documentcloud/cloud-crowd",
        "Parallel Processing for the Rest of Us"],
      [ "underscore",
        "http://documentcloud.github.com/underscore/",
        "Functional Programming Aid for Javascript. Works well with jQuery."],
      [ "jammit",
        "http://documentcloud.github.com/jammit/",
        "Industrial Strength Asset Packaging for Rails"],
      [ "closure-compiler",
        "http://github.com/documentcloud/closure-compiler",
        "A Ruby Wrapper for the Google Closure Compiler"],
      [ "docsplit",
        "http://documentcloud.github.com/docsplit/",
        "Break Apart Documents into Images, Text, Pages and PDFs"],
      [ "documentcloud.github.com",
        "http://documentcloud.github.com/",
        "Jumping Off Point for Our Open-Source Projects"]
    ]

  end

  def faq
    set_title('faq')
  end

  def document_contributors
    set_title('document_contributors')
  end

end
