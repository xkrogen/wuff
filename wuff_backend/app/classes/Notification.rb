# Superclass for EventNotification and FriendNotification. 
# Shouldn't be initialized.

class Notification

# Sends itself as a push notification to all of the user's
# associated device_tokens. 
def send_push(user)
	device_tokens = user.device_tokens
	notification_list = []
	device_tokens.each {}
#	APNS.send_notification
end

# Dummy method. Notifications should never be initialized or 
# their hashes attempted to be gotten.
def get_hash
	{}
end

# Dummy method. Notifications should never be initialized or 
# their messages attempted to be gotten.
def get_push_message
	""
end

end