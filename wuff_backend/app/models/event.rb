require 'EventNotification'
require 'FriendNotification'
require 'ConditionNotification'
require 'NoCondition'
require 'NotifyHandler'

class Event < ActiveRecord::Base

	NAME_MAX_LENGTH = 40
	# Have Rails automatically serialize the hash for storage.
	serialize :party_list, Hash
	validates :name, { presence: true, length: {maximum: NAME_MAX_LENGTH} }
	validates :admin, presence: true
	validates :party_list, presence: true
	validates :time, presence: true

	# Validates the event. Checks to ensure that all of the fields of
	# the event are valid. Returns SUCCESS if they are. Else, returns
	# ERR_INVALID_NAME, ERR_INVALID_TIME, or ERR_INVALID_FIELD.
	# Time is allowed to be up to 10 minutes in the past. 
	def is_valid?
		return ERR_INVALID_NAME if name.blank? || name.length > NAME_MAX_LENGTH
		return ERR_INVALID_TIME if time.blank? || (time < DateTime.now.ago(60*15).to_i)

		return ERR_INVALID_FIELD if (admin.blank? || party_list.blank? || !party_list.is_a?(Hash))

		return ERR_INVALID_FIELD if not party_list.has_key?(admin)

		party_list.each do |key, value|
				return ERR_INVALID_FIELD if not value.is_a?(Hash)
				return ERR_INVALID_FIELD if not value.has_key?(:status)
		end
	
		return SUCCESS
	end

	# Creates a new event with the given parameters. list_of_users should
	# be a list of integer values corresponding to user IDs. time should
	# be an integer number of seconds since the Unix epoch. Also adds
	# the event to all of the users in list_of_users, and notifies them.
	# Schedules a task to notify users 5 minutes before the event starts. 
	# Returns:
	#  * Error code ( < 0 ) upon failure
	#  * ID of new Event ( > 0 ) upon success
	def self.add_event(name, admin_id, time, user_list, description = "", location = "")

		return ERR_INVALID_FIELD if not user_list.respond_to?('each')
		return ERR_INVALID_FIELD if not user_list.include?(admin_id)
		
		user_list.each do |user_id|
			return ERR_INVALID_FIELD if not is_valid_user_id?(user_id)
		end

		description = "" if not description 
		location = "" if not location

		@event = Event.new(name: name, admin: admin_id, 
			description: description, location: location, 
			party_list: {}, time:time)
	
		@event.add_user_list(user_list, true)

		validity = @event.is_valid?
		return validity if validity < 0
		success = @event.save
		return ERR_UNSUCCESSFUL if !success
		
		@event.set_user_status(admin_id, STATUS_ATTENDING)

		@event.add_to_user_event_lists(user_list)

		@event.notify( EventNotification.new(NOTIF_NEW_EVENT, @event),
			user_list )

		# Schedule a notification only if the event is starting more than 10
		# minutes from now. 
		if  (time > (DateTime.now.to_i + 10*60))
			time_string = Time.at(time).to_datetime.to_formatted_s(:rfc822)
			notify_job_id = NotifyHandler.task_scheduler.in time_string, NotifyHandler
			NotifyHandler.add_job_mapping(notify_job_id, @event.id)
			@event.scheduler_job_id = notify_job_id
			@event.update_attribute(:scheduler_job_id, @event.scheduler_job_id)
		else
			@event.scheduler_job_id = -1
			@event.update_attribute(:scheduler_job_id, -1)
		end
		
		return @event.id
	end

	# Edits self, according to the new information given in event_info_hash. 
	# Valid keys are :name, :time, :description, :location.
	# Returns ERR_INVALID_NAME or ERR_INVALID_TIME if those fields
	# are invalid, else returns SUCCESS.
	def edit_event(event_info_hash) 
		if event_info_hash.has_key?(:name)
			new_name = event_info_hash[:name]
			return ERR_INVALID_NAME if new_name.blank? || new_name.length > NAME_MAX_LENGTH
			self.name = new_name
			self.update_attribute(:name, new_name)
		end
		if event_info_hash.has_key?(:time)
			new_time = event_info_hash[:time].to_i
				return ERR_INVALID_TIME if new_time.blank? || (new_time < DateTime.now.ago(60*15).to_i)
			self.time = new_time
			self.update_attribute(:time, new_time)
			NotifyHandler.task_scheduler.unschedule(self.scheduler_job_id) if self.scheduler_job_id != -1
			# Schedule a notification only if the event is starting more than 10
			# minutes from now. 
			if  (self.time > (DateTime.now.to_i + 10*60))
				time_string = Time.at(self.time).to_datetime.to_formatted_s(:rfc822)
				notify_job_id = NotifyHandler.task_scheduler.in time_string, NotifyHandler
				NotifyHandler.add_job_mapping(notify_job_id, self.id)
			end
		end
		if event_info_hash.has_key?(:description)
			self.description = event_info_hash[:description]
			self.update_attribute(:description, self.description)
		end
		if event_info_hash.has_key?(:location)
			self.location = event_info_hash[:location]
			self.update_attribute(:location, self.location)
		end
		return SUCCESS
	end

	# Should be called 5 minutes before the event is starting.
	# Notifies users whose status is STATUS_ATTENDING that
	# the event is about to start. 
	def notify_starting
		user_list = []
		party_list.each do |uid, uhash|
			user_list <<= uid if uhash[:status] == STATUS_ATTENDING			
		end
		notification = EventNotification.new(NOTIF_EVENT_STARTING, self)
		notify(notification, user_list, false)
	end

	# Checks if the user is listed as an admin for this event.
	def is_admin?(user_id)
		return admin == user_id
	end

	# Adds user_list to the party_list for this event.
	# If skip_attribute_update = true, doesn't update the attribute
	# within the databse (should probably only be used in add_event)
	def add_user_list(user_list, skip_attribute_update = false)
		user_hash = {}
		user_list.each do |user_id|
			user_hash[user_id] = { status: STATUS_NO_RESPONSE, 
				condition: NoCondition.new.get_hash }
		end
		self.party_list.merge!(user_hash) { |key, old, new| old }
		self.update_attribute(:party_list, self.party_list) if !skip_attribute_update
	end

	# Add this event to the user list of all users in user_list
	def add_to_user_event_lists(user_list)
		user_list.each do |users_id| 
			user = User.find(users_id)
			user.add_event(self.id)
		end
	end

	# Checks if there are currently any conditions which have been met.
	# If there are, and the user is currently not attending, their status
	# is changed to attending and they are notified of the change.
	def check_conditions
		clauses = Array.new
		party_list.each do |uid, hash|
			cond = hash[:condition]
			if cond[:cond_type] != COND_NONE && cond[:cond_met] == COND_MET
				clauses.push({ operands: false, value: uid })
			elsif cond[:cond_type] == COND_NUM_ATTENDING
				clauses.push({ operands: cond[:num_users], value: uid })

			elsif cond[:cond_type] == COND_USER_ATTENDING_ANY

				oper = Array.new
				cond[:id_list].each { |id| oper.push(id)}
				#cond[:user_list].each { |key, value| oper.push(value[:uid]) }
				clauses.push({ operands: oper, value: uid })

			elsif cond[:cond_type] == COND_USER_ATTENDING_ALL
				#cond[:user_list].each do |count, table|
				cond[:id_list].each do |id|
					clauses.push({ operands: [id], value: uid})
					#clauses.push({ operands: [table[:uid]], value: uid })
				end
			else
				if hash[:status] == STATUS_ATTENDING
					clauses.push({ operands: false, value: uid})
				else
					clauses.push({ operands: true, value: uid})
				end
			end
		end
		result = Event.compute_horn_formula(clauses)

		result.each do |uid, value|
			if party_list[uid][:condition][:cond_met] == COND_NOT_MET && party_list[uid][:condition][:cond_type] != COND_NONE
				complete_condition(uid, Condition.create_from_hash(party_list[uid][:condition])) if !value
			end
		end

	end

	# solves horn formula
	# input clauses = [ { operands: [uid] || count, value: uid } ]
	# returns hash of each value assigned to a satisfying boolean value
	def self.compute_horn_formula(clauses)
		lookup = Hash.new
		clauses.each do |clause| 
			lookup[clause[:value]] = false
		end

		begin
			changed = false
			falses = 0
			lookup.each { |key, value| falses += 1 if !value}

			clauses.each do |clause|
				if lookup[clause[:value]]
					next
				end

				if clause[:operands].kind_of?(Integer)
					lhs = (falses < clause[:operands])
				elsif clause[:operands].kind_of?(Array)
					lhs = true
					clause[:operands].each { |operand| lhs = lhs && lookup[operand] }

				else
					lhs = clause[:operands]
				end

				if lhs != lookup[clause[:value]]
					lookup[clause[:value]] = lhs
					changed = true
				end
			end
		end while changed
		return lookup
	end

	# Add a conditional acceptance for the given user.
	# Does nothing if the user is not a member of this event.
	# After adding the condition, checks if any conditions have been met
	# and takes appropriate action. 
	def add_condition(user_id, condition)
		return if not party_list.has_key?(user_id)
		party_list[user_id][:condition] = condition.get_hash
		update_attribute(:party_list, party_list)
		check_conditions
	end

	# Removes the current conditional acceptance from this user.
	# Does nothing if the user is not a member of the event or 
	# if the user doesn't currently have any conditions.
	def remove_condition(user_id)
		return if not party_list.has_key?(user_id)
		party_list[user_id][:condition] = NoCondition.new.get_hash
		update_attribute(:party_list, party_list)
	end

	# Cancels this event, removing it from all of it's associated
	# users. Also removes any scheduled tasks to notify users of the event
	# starting soon. Does not actually delete the event -- should subsequently
	# call event.destroy to remove it from the database. 
	def cancel_self
		party_list.each_key { |user_id| User.find(user_id).delete_event(self.id) }
	end

	# Removes user_id from the event. Does nothing if 
	# the user isn't currently in the event, or if
	# the admin attempts to remove itself. 
	def remove_user(user_id)
		return if is_admin?(user_id)
		party_list.delete(user_id)
		self.update_attribute(:party_list, party_list)
	end

	# Returns the user's status for this event: STATUS_ATTENDING,
	# STATUS_NOT_ATTENDING, STATUS_NO_RESPONSE. Returns nil
	# if the user is not a part of this event.
	def get_user_status(user_id)
		return nil if not party_list[user_id]
		return party_list[user_id][:status]
	end

	# Sets the user's status for this event. Does nothing if user_id
	# is not a member of this event. Triggers a rechecking of all
	# user conditions to check if any new conditions are met as a result
	# of this status change. 
	def set_user_status(user_id, new_status)
		party_list[user_id][:status] = new_status if party_list.has_key?(user_id)
		self.update_attribute(:party_list, party_list)

		check_conditions
	end

	# Notifies the users within user_list using NOTIFICATION. 
	# If user_list isn't specified, uses party_list (all users).
	# Skips the admin either way (any notification should be generated
	# by the admin), unless skip_admin is explicitly set to false. 
	def notify(notification, user_list = nil, skip_admin = true)
		if not user_list
			party_list.each_key do |key|
				next if key == admin && skip_admin
				begin 
					user = User.find(key)
				rescue ActiveRecord::RecordNotFound
					next
				end
				notification.send_push(user)
				user.post_notification(notification)
			end
		else
			user_list.each do |key|
				next if key == admin && skip_admin
				begin 
					user = User.find(key)
				rescue ActiveRecord::RecordNotFound
					next
				end
				notification.send_push(user)
				user.post_notification(notification)
			end
		end
	end

	# Returns a hash with all of the relevant information for this event.
	# { $event: eventID, $title: event_name, $creator: event_creator,  
	#   $time: time, $location: location, $description: description,
	#   $users: user_list }  
	def get_hash
		user_list = {}
		user_count = 0
		party_list.each do |key, value|
			user_count += 1
			curr_user = User.find(key)
			user_list[user_count] = { name: curr_user.name,
					email: curr_user.email, status: value[:status] }
		end
		user_list[:user_count] = user_count
		{ event: self.id, title: name, creator: admin, 
			time: time, location: location, users: user_list, description: description}
	end

	private


	# Method to change a user's status to STATUS_ATTENDING in this event
	# due to an acceptance resulting from condition. Changes their status, sets
	# the condition as met, and notifies the user of the change. For internal 
	# use by check_conditions to act on users whose conditions are met.
	# Does nothing if the user's status was already STATUS_ATTENDING or
	# if the user is not present in the party_list
	def complete_condition(user_id, condition)
		return if not party_list.has_key?(user_id)
		return if get_user_status(user_id) == STATUS_ATTENDING
		set_user_status(user_id, STATUS_ATTENDING)
		condition.met
		notif = ConditionNotification.new(NOTIF_COND_MET, self, condition)
		notify(notif, [ user_id ])
		party_list[user_id][:condition][:cond_met] = COND_MET
		update_attribute(:party_list, party_list)
	end

	# Takes in a string, USER_ID, and checks if it is a valid 
	# user id
	def self.is_valid_user_id?(user_id)
		begin 
			User.find(user_id)
		rescue ActiveRecord::RecordNotFound
			return false
		end		
		return true
	end

end
