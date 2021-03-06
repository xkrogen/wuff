# Superclass for EventNotification and FriendNotification. 
# Shouldn't be initialized.

class Notification

	# Sends itself as a push notification to all of the user's
	# associated device_tokens. 
	def send_push(user)
		return if Rails.env.test?
		device_tokens = user.device_tokens
		notification_list = []
		device_tokens.each do |token|
			notification_list <<= APNS::Notification.new(token, 
				:alert => get_push_message, :badge => 1, :sound => 'default')
		end
		APNS.send_notifications(notification_list) if not notification_list.empty?
		puts "Sending push notif to #{user.email} at #{device_tokens}. Notification message: \"#{get_push_message}\""
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