# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fulfill_session',
  :secret      => '34bc53ecacc087e3cdb706dff8b2da07ce21eb670119deb7ad04afb94e31fa6e56e8cb36210ea15523a8777819ac2cc0484b8833fa356b7b79b542ce277f43e0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
