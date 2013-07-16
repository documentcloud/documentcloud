# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
DC::Application.config.secret_key_base = '83de034b1169753f462be1c8925b62dd10afe9569b5006b685780e28b5851596c34ed5feb0c08c0451d009c537f4bf6eb9e5c8445974471442d5165498178ec7'
