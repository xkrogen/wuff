class FriendNotification < Notification

	# Friend notification type
	NOTIF_FRIEND_ADD = 4

	def initialize(friend_user)	
		@friend = friend_user
		@time = DateTime.current
	end

	def get_hash
		return { notif_type: NOTIF_FRIEND_ADD, notif_time: @time.to_i,
			friend_id: @friend.id, friend_name: @friend.name, 
			friend_email: @friend.email }
	end

	def get_push_message
		return "#{@friend.name} just added you as a friend!"
	end

end