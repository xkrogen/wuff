

APNS.host = 'gateway.sandbox.push.apple.com'
# This is the default, used for development. 

# APNS.host = 'gateway.push.apple.com' 
# This is the production server.

APNS.pem  = Rails.root.join('push', 'wuffkey.pem')
# Path to the .pem file containing private key for our server