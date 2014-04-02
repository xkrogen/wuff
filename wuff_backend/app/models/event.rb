require 'EventNotification'
require 'FriendNotification'

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
	def is_valid?
		return ERR_INVALID_NAME if name.blank? || name.length > NAME_MAX_LENGTH
		return ERR_INVALID_TIME if time.blank? || Time.at(time).to_datetime.past?

		# NOTE: For future iteration, allow time a few minutes in the past to allow for possible time lags

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
			return ERR_INVALID_TIME if new_time.blank? || Time.at(new_time).to_datetime.past?
			self.time = new_time
			self.update_attribute(:time, new_time)
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
				user_hash[user_id] = { status: STATUS_NO_RESPONSE }
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

	# Cancels this event, removing it from all of it's associated
	# users. Does not actually delete the event -- should subsequently
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
	# is not a member of this event.
	def set_user_status(user_id, new_status)
		party_list[user_id][:status] = new_status if party_list.has_key?(user_id)
		self.update_attribute(:party_list, party_list)
	end

	# Notifies the users within user_list using NOTIFICATION. 
	# If user_list isn't specified, uses party_list (all users).
	# Skips the admin either way (any notification should be generated
	# by the admin).
	def notify(notification, user_list = nil)
		if not user_list
			party_list.each_key do |key|
				next if key == admin
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
				next if key == admin
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
