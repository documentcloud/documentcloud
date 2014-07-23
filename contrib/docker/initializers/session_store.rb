DC::Application.config.session_store :cookie_store,
  :key          => 'document_cloud_session',
  :expire_after => 1.month,
  :httponly     => true,
  # Don't set "secure" -- this assumes that if you do run the site behind a
  # separate SSL terminator, you do so for the ENTIRE site. Abusing
  # DocumentCloud in this way while serving mixed content will lead to leakage
  # of session cookies.
  :secure       => false
