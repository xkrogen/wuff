require 'user'

class GroupsController < ApplicationController

	# POST /group/create_group
	# Creates a new group and stores it in the db
	# * On success, stores the group in the database
	# * On success, adds the group to each member
	# * On success, returns JSON { err_code: SUCCESS, :group}
	# * On failure, returns JSON { :err_code }
	def create_group

		return if not signed_in_response

		if not params[:user_list].respond_to?('split')
			respond(ERR_INVALID_FIELD)
			return
		end

		user_list = params[:user_list].split(",").map do |email|
			user = User.find_by(email: email.strip)
			if user == nil
				respond(ERR_INVALID_FIELD)
				return 
			end
			user.id
		end

		rval = Group.add_group(params[:name], user_list, params[:description])

		if rval < 0
  		respond(rval)
  	else
  		respond(SUCCESS, { group: rval } )
  	end
  end

	# POST /group/add_users
	# Adds users to the group: adds them to the group's user_list,
	# and adds the group to their group_list.
	# You must be signed in, and you must be a member of the group
	# for this call to succeed. 
	# Duplicate users (users already in the group) will be ignored.
	def add_users
		return if not signed_in_response
		return if not get_group
		return if not member_of_group

		user_list = params[:user_list].split(',').map do |email|
			user = User.find_by(email: email.strip)
			if not user
				respond(ERR_INVALID_FIELD)
				return
			end
			user.id
		end

		curr_user_list = @group.user_list
		user_list.delete_if { |user_id| curr_user_list.include?(user_id) }

		@group.add_user_list(user_list)
		@group.add_to_user_group_lists(user_list)

		respond(SUCCESS)
	end

  # POST /group/view
  # Returns relevant information about the given group. Must be a 
  # member of the group for this to succeed.
  def view
		return if not signed_in_response
		return if not get_group
		return if not member_of_group
		respond(SUCCESS, @group.get_hash)
	end

	# DELETE /group/delete_group
	# Deletes the given group. Removes it from all of the associated
	# user's group_lists, and removes it from the database.
	# Will fail if not called by a member of the group.
	def delete_group
		return if not signed_in_response
		return if not get_group
		return if not member_of_group

		@group.delete_self
		@group.destroy
		respond(SUCCESS)
	end

	# POST /group/edit_group
	# Edits the given group to have new parameters as passed. Any 
	# field not passed will remain unchanged. Must be a member of the group.
	def edit_group
		return if not signed_in_response
		return if not get_group
		return if not member_of_group

		group_info_hash = {}
		group_info_hash[:name] = params[:name] if params.has_key?(:name)
		group_info_hash[:description] = params[:description] if params[:description]
		rval = @group.edit_group(group_info_hash)
		respond(rval)
	end

	# DELETE /group/remove_user
	# Removes the given user from the group. You must be a member to
	# remove people, and you can remove yourself. 
	def remove_user
		return if not signed_in_response
		return if not get_group
		return if not member_of_group

		begin 
			user_to_remove = User.find_by(email: params[:user_remove])
		rescue ActiveRecord::RecordNotFound
			respond(ERR_INVALID_FIELD)
			return
		end

		@group.remove_user(user_to_remove.id)
		user_to_remove.delete_group(@group.id)
		respond(SUCCESS)
	end

	private

	# Checks if there is a properly signed in user. If there is, returns
	# true. If not, responds with ERR_INVALID_SESSION and returns false.
	def signed_in_response
		if !signed_in?
			respond(ERR_INVALID_SESSION)
			return false
		end
		true
	end

	# Sets @group to the group located in params[:group]. If none exists,
	# responds with ERR_INVALID_FIELD and returns nil. Otherwise,
	# returns the group object that was found. 
	def get_group
		begin
			@group = Group.find(params[:group].to_i)
		rescue ActiveRecord::RecordNotFound
			respond(ERR_INVALID_FIELD)
			return false
		end
		true
	end

	# Checks to see if the currently logged in user is a member 
	# of this group. If not, responds with ERR_INVALID_PERMISSIONS
	# and returns false. If it is, returns true.
	def member_of_group
		if not @group.user_list.include?(current_user.id)
			respond(ERR_INVALID_PERMISSIONS)
			return false
		end
		true
	end

	# Responds. Always includes err_code set to ERROR (SUCCESS by default). 
	# Additional response fields can be passed as a hash to ADDITIONAL.
	def respond(error = SUCCESS, additional = {})
		response = { err_code: error }.merge(additional)
		render json: response, status: 200
	end

	# Checks if the request was made by a properly signed in user.  
	def signed_in?
		return current_user != nil
	end

  # Finds the User with the remember_token stored in the session with the key :current_user_token
  # Logging in sets the session value and logging out removes it.
  def current_user
  	token = User.hash(cookies[:current_user_token])
  	return User.find_by(remember_token: token)
  end

end
