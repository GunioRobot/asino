# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_money_session',
  :secret      => '6de6dc6c20460ddffea800656d4f26a7bbba79ee271e162b66181a2b15a7b04264fc10fd64badf7db7e2099847d9c97ea967a561c868e4e86e54e2a05c2c4db4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
