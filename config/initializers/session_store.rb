# Be sure to restart your server when you modify this file.

DC::Application.config.session_store :cookie_store,
  :key          => 'document_cloud_session',
  :expire_after => 1.month,
  :httponly     => true,
  :secure       => true
