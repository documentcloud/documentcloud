xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "DocumentCloud Featured Reporting"
    xml.description "Featured reports that have utilized DocumentCloud to assist with the creation or presentation of the article or series"
    xml.link featured_index_url

    @reports.each do | report |
      xml.item do
        xml.title "#{report.title} by the #{report.organization} on #{report.article_date.strftime('%B %e, %Y')}"
        xml.description report.writeup_html
        xml.pubDate report.created_at.to_s(:rfc822)
        xml.link "#{featured_index_url}#{report.id}"
        xml.guid "#{featured_index_url}#{report.id}"
      end
    end
  end
end
