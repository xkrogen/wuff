class Event < ActiveRecord::Base
	# Have Rails automatically serialize the hash for storage.
	serialize :party_list, Hash
	validates :name, { presence: true, length: {maximum: MAX_NAME_LENGTH} }
	validates :admin, presence: true
	validates :party_list, presence: true

	MAX_NAME_LENGTH = 40

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
		return ERR_INVALID_NAME if not name.valid?
		return ERR_INVALID_TIME if Time.at(time).to_datetime.past?
		return ERR_INVALID_FIELD if not (admin.valid? && party_list.valid?)
		return SUCCESS
	end

end
