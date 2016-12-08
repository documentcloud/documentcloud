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

  def bootstrap_alert_class_for(flash_type)
    {
      success: 'alert-success',
      error:   'alert-danger',
      warning: 'alert-warning',
      alert:   'alert-warning',
      notice:  'alert-info',
    }[flash_type.to_sym] || flash_type.to_s
  end
  
  def external_link_to(text, url, options = {})
    link_to text, url, options.merge({ target: '_blank', rel: 'noopener' })
  end

end
