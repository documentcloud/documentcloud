# Be sure to restart your server when you modify this file.

DC::Application.config.session_store :cookie_store,
  key:      'document_cloud_session',
  # Keep in sync with `Account#refresh_credentials`
  expires:  1.month.from_now,
  httponly: true,
  secure:   true
