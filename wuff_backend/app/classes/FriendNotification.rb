class FriendNotification

	# Friend notification type
	NOTIF_FRIEND_ADD = 4

	def initialize(friend_user)	
		@friend = friend_user
		@time = DateTime.current
	end

	def getHash
		return { notif_type: NOTIF_FRIEND_ADD, notif_time: @time.to_i,
			friend_id: @friend.id, friend_name: @friend.name, 
			friend_email: @friend.email }
	end

end