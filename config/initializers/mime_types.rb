# Be sure to restart your server when you modify this file.

mime_types = {
  :htm  => "text/html",
  :rdf  => "application/rdf+xml",
  :gz   => "application/x-gzip",
  :svg  => "image/svg+xml",
  :ttf  => "application/x-font-truetype",
  :eot  => "application/vnd.ms-fontobject",
  :woff => "application/font-woff"
}

mime_types.each do |ext, mime_type|
  Mime::Type.register mime_type, ext
end
