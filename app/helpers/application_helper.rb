module ApplicationHelper

  def compose_title(title)
    (title ? "#{title} | " : '') + 'DocumentCloud'
  end

  def compose_canonical_url(canonical_url)
    canonical_url || request.url
  end

  def compose_html_classes(html_classes)
    html_classes = html_classes.is_a?(String) ? html_classes.split : [html_classes]
    html_classes.push("dc-authenticated") if !!@current_account
    html_classes.push("env-#{Rails.env}").flatten.join(' ')
  end

end
