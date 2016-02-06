module ApplicationHelper

  def compose_title(title)
    (title ? "#{title} | " : '') + 'DocumentCloud'
  end

end
