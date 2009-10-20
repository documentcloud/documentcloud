# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key          => 'document_cloud_session',
  :secret       => '83de034b1169753f462be1c8925b62dd10afe9569b5006b685780e28b5851596c34ed5feb0c08c0451d009c537f4bf6eb9e5c8445974471442d5165498178ec7',
  :expire_after => 1.month
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
