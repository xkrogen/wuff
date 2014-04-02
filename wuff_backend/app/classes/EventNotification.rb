class EventNotification < Notification

	# Event notification types
	NOTIF_NEW_EVENT = 1
	NOTIF_DELETE_EVENT = 2
	NOTIF_EDIT_EVENT = 3

	def initialize(notif_type, event)	
		@type = notif_type
		@event = event
		@time = DateTime.current
	end

	def get_hash
		admin = User.find(@event.admin)
		return { notif_type: @type, notif_time: @time.to_i, event: @event.id, 
			name: @event.name, creator: { name: admin.name, email: admin.email },
			time: @event.time, location: @event.location }
	end

	def get_push_message
		case @type
		when NOTIF_NEW_EVENT
			return "#{User.find(@event.admin).name} invited you to #{@event.name}"
		when NOTIF_DELETE_EVENT
			return "#{@event.name} has been cancelled."
		when NOTIF_EDIT_EVENT
			return "#{@event.name} has been updated!"
		end
	end

end