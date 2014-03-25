class Group < ActiveRecord::Base

	NAME_MAX_LENGTH = 40
	# Have Rails automatically serialize the hash for storage.
	serialize :user_list, Array
	validates :name, { presence: true, length: {maximum: NAME_MAX_LENGTH} }
	validates :user_list, presence: true

	# Validates the group. Checks to ensure that all of the fields of
	# the group are valid. Returns SUCCESS if they are. Else, returns
	# ERR_INVALID_NAME, or ERR_INVALID_FIELD.
	def is_valid?
		return ERR_INVALID_NAME if name.blank? || name.length > NAME_MAX_LENGTH

		return ERR_INVALID_FIELD if user_list.blank?

		return SUCCESS
	end

	# Creates a new group with the given parameters. user_list should
	# be a list of integer values corresponding to user IDs. Also adds
	# the group to all of the users in user_list.
	# Returns:
	#  * Error code ( < 0 ) upon failure
	#  * ID of new Group ( > 0 ) upon success
	def self.add_group(name, user_list, description = "")

		return ERR_INVALID_FIELD if not user_list.respond_to?('each')
		
		user_list.each do |user_id|
			return ERR_INVALID_FIELD if not is_valid_user_id?(user_id)
		end

		@group = Group.new(name: name, description: description, 
			user_list: [])
	
		@group.add_user_list(user_list, true)

		validity = @group.is_valid?
		return validity if validity < 0
		success = @group.save
		return ERR_UNSUCCESSFUL if !success
		
		@group.add_to_user_group_lists(user_list)

		return @group.id
	end

	# Edits self, according to the new information given in group_info_hash. 
	# Valid keys are :name and :description
	# Returns ERR_INVALID_NAME if the name is invalid, else SUCCESS.
	def edit_group(group_info_hash) 
		if group_info_hash.has_key?(:name)
			new_name = group_info_hash[:name]
			return ERR_INVALID_NAME if new_name.blank? || new_name.length > NAME_MAX_LENGTH
			self.name = new_name
			self.update_attribute(:name, new_name)
		end
		if group_info_hash.has_key?(:description)
			self.description = group_info_hash[:description]
			self.update_attribute(:description, self.description)
		end
		return SUCCESS
	end

	# Adds user_list to the user_list for this group.
	# If skip_attribute_update = true, doesn't update the attribute
	# within the database (should probably only be used in add_group)
	def add_user_list(user_list, skip_attribute_update = false)
		self.user_list |= user_list
		self.update_attribute(:user_list, self.user_list) if !skip_attribute_update
	end

	# Add this group to the group list of all users in user_list
	def add_to_user_group_lists(user_list)
		user_list.each do |users_id| 
			user = User.find(users_id)
			user.add_group(self.id)
		end
	end

	# Deletes this group, removing it from all of it's associated
	# users. Does not actually delete the group -- should subsequently
	# call group.destroy to remove it from the database. 
	def delete_self
		user_list.each { |uid| User.find(uid).delete_group(self.id) }
	end

	# Removes user_id from the group. Does nothing if 
	# the user isn't currently in the group.
	def remove_user(user_id)
		user_list.delete(user_id)
		self.update_attribute(:user_list, user_list)
	end

	# Returns a hash with all of the relevant information for this group.
	# { $group: groupID, $name: group_name, $description: 
	#    group_description, $users: user_list }  
	def get_hash
		user_list_out = {}
		user_count = 0
		user_list.each do |uid|
			user_count += 1
			curr_user = User.find(uid)
			user_list_out[user_count] = { name: curr_user.name,
					email: curr_user.email }
		end
		user_list_out[:user_count] = user_count
		{ group: self.id, title: name, 
			users: user_list_out, description: description}
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
