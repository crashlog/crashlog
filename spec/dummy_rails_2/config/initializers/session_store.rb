# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dummy_session',
  :secret      => 'f8fa2bdad5cacb48464bca0853feb6923ed070084fb65e1838b72f6ef7c3dc2e3a56a26585a322d202d7c4b99e6a18ebf22a14b5c4ac31a815486b9c201d760e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
