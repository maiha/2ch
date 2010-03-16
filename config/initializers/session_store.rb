# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_2ch_session',
  :secret      => 'a84b457886f33fb047a396d6a561d9b6036bf2c479e28ae834bc8dd1275a52a6861d07fe078964a75d60921584751cb8e507ce8bd2ff64941ce5aa850a38dfc2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
