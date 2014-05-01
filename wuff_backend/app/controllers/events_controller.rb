#require 'user'
require 'Condition'
require 'NumberCondition'
require 'UserCondition'

class EventsController < ApplicationController

	# POST /event/create_event
	# Creates a new event and stores it in the db
	# * On success, stores the event in the database
	# * On success, adds the event to each invited user and notifies them
	# * On success, returns JSON { err_code: SUCCESS, :event}
	# * On failure, returns JSON { :err_code }
	def create_event

		return if not signed_in_response
		creator = current_user

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

		rval = Event.add_event(params[:title], creator.id, params[:time].to_i,
			user_list, params[:description], params[:location])

		if rval < 0
  		respond(rval)
  	else
  		respond(SUCCESS, { event: rval } )
  	end
  end

	# POST /event/invite_users
	# Invites users to the event: adds them to the event's party_list,
	# adds the event to their event_list, and notifies them.
	# You must be signed in, and you must be the admin of the event
	# for this call to succeed. 
	# Duplicate users (users already in the event) will be ignored.
	def invite_users
		return if not signed_in_response
		return if not get_event
		return if not user_admin

		user_list = params[:user_list].split(',').map do |email|
			user = User.find_by(email: email.strip)
			if not user
				respond(ERR_INVALID_FIELD)
				return
			end
			user.id
		end

		curr_party_list = @event.party_list
		user_list.delete_if { |user_id| curr_party_list.has_key?(user_id) }

		@event.add_user_list(user_list)
		@event.add_to_user_event_lists(user_list)
		@event.notify( EventNotification.new(NOTIF_NEW_EVENT, @event), user_list)

		respond(SUCCESS)
	end

	# POST /event/invite_group
	# Invites all of the members of the group to the event: 
	# adds them to the event's party_list,
	# adds the event to their event_list, and notifies them.
	# You must be signed in, and you must be the admin of the event
	# for this call to succeed. 
	# Duplicate users (users already in the event) will be ignored.
	# Returns ERR_INVALID_FIELD if not a valid group or event.
	def invite_group
		return if not signed_in_response
		return if not get_event
		return if not user_admin

		begin
			group = Group.find(params[:group])
		rescue ActiveRecord::RecordNotFound
			respond(ERR_INVALID_FIELD)
			return
		end

		user_list = group.user_list
		curr_party_list = @event.party_list
		user_list.delete_if { |user_id| curr_party_list.has_key?(user_id) }

		@event.add_user_list(user_list)
		@event.add_to_user_event_lists(user_list)
		@event.notify( EventNotification.new(NOTIF_NEW_EVENT, @event), user_list)

		respond(SUCCESS)
	end

  # POST /event/update_user_status
  # Updates the currently logged in user's status within this event.
  # Does nothing when attempting to change status within an 
  # event that the user is not a member of.
  def update_user_status
		return if not signed_in_response
		return if not get_event
		return if not member_of_event
		
		new_status = params[:status]
		if not [STATUS_NO_RESPONSE, STATUS_NOT_ATTENDING,
			STATUS_ATTENDING].include?(new_status)
			respond(ERR_INVALID_FIELD)
			return
		end

		@event.set_user_status(current_user.id, new_status)
		respond(SUCCESS)
  end

  # POST /event/view
  # Returns relevant information about the given event. 
  def view
		return if not signed_in_response
		return if not get_event
		return if not member_of_event
		respond(SUCCESS, @event.get_hash)
	end

	# DELETE /event/cancel_event
	# Deletes the given event. Removes it from all of the associated
	# user's event_lists, and removes it from the database.
	# Will fail if not called by the admin.
	def cancel_event
		return if not signed_in_response
		return if not get_event
		return if not user_admin

		@event.cancel_self
		@event.destroy
		respond(SUCCESS)
	end

	# POST /event/edit_event
	# Edits the given event to have new parameters as passed. Any 
	# field not passed will remain unchanged. Must be admin.
	def edit_event
		return if not signed_in_response
		return if not get_event
		return if not user_admin

		event_info_hash = {}
		event_info_hash[:name] = params[:title] if params.has_key?(:title)
		event_info_hash[:location] = params[:location] if params[:location]
		event_info_hash[:description] = params[:description] if params[:description]
		event_info_hash[:time] = params[:time].to_i if params[:time]
		rval = @event.edit_event(event_info_hash)
		respond(rval)
	end

	# DELETE /event/remove_user
	# Removes the given user from the event only if the currently
	# signed in user is the admin for the event. You cannot 
	# remove the admin from the event.
	def remove_user
		return if not signed_in_response
		return if not get_event
		return if not user_admin

		begin 
			user_to_remove = User.find_by(email: params[:user_remove])
		rescue ActiveRecord::RecordNotFound
			respond(ERR_INVALID_FIELD)
			return
		end

		if @event.is_admin?(user_to_remove.id)
			respond(ERR_INVALID_FIELD)
			return false
		end

		@event.remove_user(user_to_remove.id)
		user_to_remove.delete_event(@event.id)
		respond(SUCCESS)
	end

	# POST /event/add_conditional_acceptance
	# Adds a conditional acceptance for this user. A user’s status will automatically
	# be changed to STATUS_ATTENDING only if the specified condition is met. 
	def add_cond_acceptance
		return if not signed_in_response
		return if not get_event

		if params[:condition_type] == COND_NUM_ATTENDING
			if params[:condition] < 0
				respond(ERR_INVALID_FIELD)
				return
			end
			@event.add_condition(current_user, NumberCondition.new(params[:condition]))
			respond(SUCCESS)
		elsif params[:condition_type] == COND_USER_ATTENDING_ANY
			user_list = params[:condition].split(",").map do |email|
				user = User.find_by(email: email.strip)
				if user == nil
					respond(ERR_INVALID_FIELD)
					return 
				end
				user.id
			end
			@event.add_condition(current_user, UserCondition.new(COND_USER_ATTENDING_ANY, params[:condition]))
			respond(SUCCESS)
		elsif params[:condition_type] == COND_USER_ATTENDING_ALL
			user_list = params[:condition].split(",").map do |email|
				user = User.find_by(email: email.strip)
				if user == nil
					respond(ERR_INVALID_FIELD)
					return 
				end
				user.id
			end
			@event.add_condition(current_user, UserCondition.new(COND_USER_ATTENDING_ALL, params[:condition]))
			respond(SUCCESS)
		else
			respond(ERR_INVALID_FIELD)
		end
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

	# Sets @event to the event located in params[:event]. If none exists,
	# responds with ERR_INVALID_FIELD and returns nil. Otherwise,
	# returns the event object that was found. 
	def get_event
		begin
			@event = Event.find(params[:event].to_i)
		rescue ActiveRecord::RecordNotFound
			respond(ERR_INVALID_FIELD)
			return false
		end
		true
	end

	# Checks to see if the currently logged in user is the admin
	# for this event. If not, responds with ERR_INVALID_PERMISSIONS
	# and returns false. If it is, returns true. 
	def user_admin
		if not @event.is_admin?(current_user.id)
			respond(ERR_INVALID_PERMISSIONS)
			return false
		end
		true
	end

	# Checks to see if the currently logged in user is a member
	# of this event. If not, responds with ERR_INVALID_PERMISSIONS
	# and returns false. If it is, returns true.
	def member_of_event
		if @event.get_user_status(current_user.id) == nil
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
