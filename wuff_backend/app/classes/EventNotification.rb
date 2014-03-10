class EventNotification

	# Event notification types
	NOTIF_NEW_EVENT = 1
	NOTIF_DELETE_EVENT = 2
	NOTIF_EDIT_EVENT = 3

	def initialize(notif_type, event)	
		@type = notif_type
		@event = event
		@time = DateTime.current
	end

	def getHash
		return { notif_type: @type, notif_time: @time.to_i, event: @event.id, 
			name: @event.name, creator: @event.admin, time: @event.time,  
			location: @event.location }
	end

end