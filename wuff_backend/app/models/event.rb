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

		return ERR_INVALID_FIELD if (admin.blank? || party_list.blank? || !party_list.is_a?(Hash))

		party_list_has_creator = false
		party_list.each do |key, value|
				party_list_has_creator = true if (key == admin)
				return ERR_INVALID_FIELD if not value.is_a?(Hash)
				return ERR_INVALID_FIELD if not value.has_key?(:status)
		end
		return ERR_INVALID_FIELD if !party_list_has_creator
		return SUCCESS
	end

	# Creates a new event with the given parameters. list_of_users should
	# be a list of integer values corresponding to user IDs. time should
	# be an integer number of seconds since the Unix epoch. Also adds
	# the event to all of the users in list_of_users, and notifies them.
	# Returns:
	#  * Error code ( < 0 ) upon failure
	#  * ID of new Event ( > 0 ) upon success
	def self.add_event(name, admin_id, time, list_of_users, description = "", location = "")

		user_list = {}

		return ERR_INVALID_FIELD if not list_of_users.respond_to?('each')
		return ERR_INVALID_FIELD if not list_of_users.include?(admin_id)
		
		list_of_users.each do |user_id|
			if !is_valid_user_id?(user_id)
				return ERR_INVALID_FIELD
			else
				user_list[user_id] = { status: STATUS_NO_RESPONSE }
				user_list_has_admin = true if user_id == admin_id
			end
		end

		user_list[admin_id][:status] = STATUS_ATTENDING 

		@event = Event.new(name: name, admin: admin_id, 
			description: description, location: location, 
			party_list: user_list, time:time)
	
		validity = @event.is_valid?
		return validity if validity < 0
		success = @event.save
		return ERR_UNSUCCESSFUL if !success
		
		user_list.each_key do |users_id| 
			user = User.find(users_id)
			user.add_event(@event.id)
		end

		@event.notify( EventNotification.new(NOTIF_NEW_EVENT, @event) )

		return @event.id
	end

	# Returns the user's status for this event: STATUS_ATTENDING,
	# STATUS_NOT_ATTENDING, STATUS_NO_RESPONSE. Returns nil
	# if the user is not a part of this event.
	def get_user_status(user_id)
		party_list[user_id][:status]
	end

	# Sets the user's status for this event. Does nothing if user_id
	# is not a member of this event.
	def set_user_status(user_id, new_status)
		party_list[user_id][:status] = new_status if party_list.has_key?(user_id)
		self.update_attribute(:party_list, party_list)
	end

	# Notifies all of the users within party_list using NOTIFICATION. 
	def notify(notification)
		party_list.each_key do |key|
			next if key == admin
			begin 
				user = User.find(key)
			rescue ActiveRecord::RecordNotFound
				next
			end
			user.post_notification(notification)
		end
	end

	# Returns a hash with all of the relevant information for this event.
	# { $event: eventID, $name: event_name, $creator: event_creator,  
	#   $time: time, $location: location, $users: user_list }  
	def get_hash
		user_list = []
		status_list = []
		party_list.each do |key, value|
			user_list << key
			status_list << value[:status]
		end
		{ event: self.id, name: name, creator: admin, 
			time: time, location: location, users: user_list.join(','),
			status_list: status_list.join(',')}
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
