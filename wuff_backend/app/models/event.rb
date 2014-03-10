class Event < ActiveRecord::Base
	# Have Rails automatically serialize the hash for storage.
	serialize :party_list, Hash
	validates :name, { presence: true, length: {maximum: NAME_MAX_LENGTH} }
	validates :admin, presence: true
	validates :party_list, presence: true
	validates :time, presence: true

	NAME_MAX_LENGTH = 40

	# Success return code
	SUCCESS = 1
	# Invalid name: Name must exist and have max length MAX_NAME_LENGTH
	ERR_INVALID_NAME = -1 
	# Invalid time: Time must be a valid time
	ERR_INVALID_TIME = -10
	# Invalid field: Generic, one of the fields is invalid. 
	ERR_INVALID_FIELD = -6
	# Generic error for an unsuccessful action
	ERR_UNSUCCESSFUL = -7

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

	def notify(notification)
		party_list.each_key do |key|
			next if key == admin
			begin 
				user = User.find(key)
			rescue ActiveRecord::RecordNotFound
				next
			end
			user.notify(notification)
		end
	end

end
