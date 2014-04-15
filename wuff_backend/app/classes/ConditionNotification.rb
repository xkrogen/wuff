
require 'Notification'

class ConditionNotification < Notification

	# Conditional notification type
	NOTIF_COND_MET = 5

	def initialize(notif_type, event, condition)	
		@type = notif_type
		@event = event
		@time = DateTime.current
		@condition = condition
	end

	def get_hash
		admin = User.find(@event.admin)
		return { notif_type: @type, notif_time: @time.to_i, event: @event.id, 
			name: @event.name, creator: admin.get_hash,
			time: @event.time, location: @event.location , 
			condition: @condition.get_hash }
	end

	def get_push_message
		"Conditions met for #{@event.name}. You are now attending!"
	end

end