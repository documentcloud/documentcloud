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

    @partners = [
      ["Gotham Gazette", "http://www.gothamgazette.com/"],
      ["National Security Archive", "http://www.gwu.edu/~nsarchiv/"],
      ["New York Times", "http://www.nytimes.com/"],
      ["ProPublica", "http://www.propublica.org/"],
      ["Talking Points Memo", "http://www.talkingpointsmemo.com/"]
    ]

    @contributors = [
      ["ACLU National Security Project", "http://www.aclu.org/national-security"],
      ["Arizona Republic", "http://www.azcentral.com/"],
      ["Boston Globe", "http://www.boston.com/bostonglobe/"],
      ["California Watch", "http://www.centerforinvestigativereporting.org/projects/californiawatch/"],
      ["Center for Democracy and Technology / OpenCRS", "http://opencrs.com/", "Congressional Research Service reports, opened."],
      ["Center for Investigative Reporting", "http://www.centerforinvestigativereporting.org/"],
      ["Center for Public Integrity", "http://www.publicintegrity.org/"],
      ["Centre for Investigative Journalism, City University London", "http://www.city.ac.uk/study/courses/arts/investigative-journalism-ma-diploma"],
      ["Chicago Tribune", "http://www.chicagotribune.com/"],
      ["Circle of Blue", "http://www.circleofblue.org/"],
      ["Dallas Morning News", "http://www.dallasnews.com/"],
      ["Forbes", "http://www.forbes.com/"],
      ["Investigate West", "http://invw.org/"],
      ["Investigative Reporting Workshop at American University", "http://investigativereportingworkshop.org/"],
      ["Los Angeles Times", "http://www.latimes.com/"],
      ["Miami Herald", "http://www.miamiherald.com/"],
      ["MinnPost", "http://www.minnpost.com/"],
      ["Mother Jones", "http://motherjones.com/"],
      ["MSNBC", "http://www.msnbc.msn.com/"],
      ["National Public Radio", "http://www.npr.org"],
      ["NewsHour", "http://www.pbs.org/newshour/"],
      ["Press & Sun-Bulletin", "http://Pressconnects.com", "Binghamton, NY"],
      ["Public Radio International (PRI)", "http://pri.org/"],
      ["Public.Resource.Org", "http://public.resource.org/"],
      ["SF Public Press", "http://sfpublicpress.org/"],
      ["St. Petersburg Times", "http://www.tampabay.com/"],
      ["Sunlight Foundation", "http://www.sunlightfoundation.com/"],
      ["The Atlantic", "http://www.theatlantic.com/"],
      ["The New Yorker", "http://www.newyorker.com/"],
      ["The Seattle Times", "http://seattletimes.nwsource.com"],
      ["Thomson Reuters", "http://thomsonreuters.com/"],
      ["Transactional Records Access Clearinghouse (TRAC)", "http://trac.syr.edu/aboutTRACgeneral.html"],
      ["UBC School of Journalism", "http://www.journalism.ubc.ca/"],
      ["UCSF's Legacy Tobacco Documents Library and Drug Industry Document Archive", "http://legacy.library.ucsf.edu/"],
      ["Vancouver Sun", "http://www.vancouversun.com/"],
      ["Voice of San Diego", "http://www.voiceofsandiego.org/"],
      ["Washington Post", "http://www.wpost.com"],
      ["WNYC Radio", "http://www.wnyc.org"]
    ]

  end

  def who_we_are
    set_title('who_we_are')
  end

  def news
    set_title('news')
    @news = [
      [ "DocumentCloud aims to release a public beta in March 2010",
        "http://blogs.journalism.co.uk/editors/2010/01/06/documentcloud-aims-to-release-a-public-beta-in-march-2010/",
        "Journalism.co.uk",
        Date.civil(2010, 1, 6)],
      [ "DocumentCloud still looking for more collaborators; Amazon Web Services set to partner",
        "http://blogs.journalism.co.uk/editors/2009/09/28/documentcloud-still-looking-for-more-collaborators-amazon-web-services-set-to-partner/",
        "Journalism.co.uk",
        Date.civil(2009, 9, 28)],
      [ "OpenCalais joins DocumentCloud, set to host a wealth of primary sources",
        "http://www.editorsweblog.org/multimedia/2009/09/opencalais_joins_documentcloud_set_to_ho.php",
        "Editors Weblog",
        Date.civil(2009, 9, 25)],
      [ "The Atlantic, The New Yorker, Mother Jones, WNYC, More Join Data Archive Experiment DocumentCloud",
        "http://www.observer.com/2009/media/atlantic-new-yorker-mother-jones-wnyc-more-join-data-archive-experiment-documentcloud",
        "The New York Observer",
        Date.civil(2009, 9, 24)],
      [ "Thomson Reuters partners KNC winner DocumentCloud",
        "http://www.journalism.co.uk/2/articles/535928.php",
        "Journalism.co.uk",
        Date.civil(2009, 9, 24)],
      [ "More News from DocumentCloud",
        "http://www.knightblog.org/more-news-from-documentcloud/",
        "Knightblog",
        Date.civil(2009, 9, 24)],
      [ "DocumentCloud adds impressive list of investigative-journalism outfits",
        "http://www.niemanlab.org/2009/09/documentcloud-adds-impressive-list-of-investigative-journalism-outfits/",
        "Nieman Journalism Lab",
        Date.civil(2009, 9, 24)],
      [ "“Don't leave me alone in a room with CloudCrowd”",
        "http://ruby5.envylabs.com/episodes/11-episode-10-september-15-2009",
        "Ruby5 Podcast",
        Date.civil(2009, 9, 15)],
      [ "Coming soon: Data mining made easier",
        "http://niemanwatchdog.org/index.cfm?fuseaction=Showcase.view&showcaseid=00111",
        "Nieman Watchdog",
        Date.civil(2009, 7, 11)],
      [ "Knight Grantee Points to One Future of Public Information Sharing",
        "http://techpresident.com/blog-entry/knight-grantee-points-one-future-public-information-sharing",
        "TechPresident",
        Date.civil(2009, 6, 25)],
      [ "<i>Times</i>, ProPublica Journos Get $719,500 for DocumentCloud",
        "http://www.observer.com/2009/media/whos-saving-journalism",
        "The New York Observer",
        Date.civil(2009, 6, 18)],
      [ "Archived Chat: ProPublica, NYT Team on How DocumentCloud Will Improve Investigations",
        "http://www.poynter.org/column.asp?id=101&aid=165353",
        "Poynter Online",
        Date.civil(2009, 6, 18)],
      [ "What is DocumentCloud? Answers from Umansky and Pilhofer ",
        "http://www.journalism.co.uk/2/articles/534819.php",
        "Journalism.co.uk",
        Date.civil(2009, 6, 18)],
      [ "Knight Foundation Awards $5.1 Million To News Challenge Winners",
        "http://www.mediabistro.com/fishbowlny/awards/knight_foundation_awards_51_million_to_news_challenge_winners_119339.asp",
        "FishbowlNY",
        Date.civil(2009, 6, 18)],
      [ "Knight News Challenge Winners Named—Get $5.1 Million",
        "http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003985130",
        "Editor & Publisher",
        Date.civil(2009, 6, 17)],
      [ "The Knight Foundation makes some bets on the future",
        "http://blogs.chicagoreader.com/news-bites/2009/06/17/knight-foundation-makes-some-bets-future/",
        "Chicago Reader",
        Date.civil(2009, 6, 17)],
      [ "DocumentCloud Gets Funding to Create Research Memory Bank in the Sky",
        "http://www.readwriteweb.com/archives/documentcloud_gets_funding_to_create_research_memo.php",
        "ReadWriteWeb",
        Date.civil(2009, 6, 17)],
      [ "NY Times/ProPublica Team Wins $719,000 Knight News Challenge Grant",
        "http://www.wired.com/epicenter/2009/06/ny-timespropublica-team-wins-719000-knight-news-challenge-grant/",
        "Wired",
        Date.civil(2009, 6, 17)],
      [ "Knight News Challenge: A grant to DocumentCloud promises a data boost for investigative journalism",
        "http://www.niemanlab.org/2009/06/knight-news-challenge-a-grant-to-documentcloud-promises-a-data-boost-for-investigative-journalism/",
        "Nieman Journalism Lab",
        Date.civil(2009, 6, 17)],
      [ "ProPublica, NY Times Team Wins Knight News Challenge Grant for Investigative Document Site",
        "http://www.poynter.org/column.asp?id=101&aid=165353",
        "Poynter Online",
        Date.civil(2009, 6, 17)],
      [ "Filling  in the Blanks on DocumentCloud",
        "http://www.ojr.org/ojr/people/eulken/200901/1632/",
        "Online Journalism Review",
        Date.civil(2009, 1, 28)],
      [ "Knight News Challenge 2009: The Collaborative DocumentCloud",
        "http://www.journalism.co.uk/2/articles/532990.php",
        "Journalism.co.uk",
        Date.civil(2008, 12, 5)],
      [ "DocumentCloud: The Innovation $1m in Knight money could buy",
        "http://www.niemanlab.org/2008/11/documentcloud-the-innovation-1m-in-knight-money-could-buy/",
        "Nieman Journalism Lab",
        Date.civil(2008, 11, 19)]
    ]
  end

end
