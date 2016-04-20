module ApplicationHelper

  def compose_title(title)
    (title ? "#{title} | " : '') + 'DocumentCloud'
  end

  def compose_canonical_url(canonical_url)
    canonical_url || request.url
  end

  def compose_html_classes(html_classes)
    html_classes = html_classes.split if html_classes.is_a?(String)
    [html_classes].flatten.join(' ')
  end

end
