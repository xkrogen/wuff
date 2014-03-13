require 'user'

class EventsController < ApplicationController

	# POST /event/create_event
	# Creates a new event and stores it in the db
	# * On success, stores the event in the database
	# * On success, adds the event to each invited user and notifies them
	# * On success, returns JSON { err_code: SUCCESS, :event}
	# * On failure, returns JSON { :err_code }
	def create_event
		
		if !signed_in?
			respond(ERR_INVALID_SESSION)
			return
		end

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

		rval = Event.add_event(params[:name], creator.id, params[:time].to_i,
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
	def invite_users
		
		if !signed_in?
			respond(ERR_INVALID_SESSION)
			return
		end

		event_id = params[:event].to_i
		begin
			event = Event.find(event_id)
		rescue ActiveRecord::RecordNotFound
			respond(ERR_INVALID_FIELD)
			return
		end
		
		if not event.is_admin?(current_user)
			respond(ERR_INVALID_PERMISSIONS)
			return
		end

		user_list = params[:user_list].split(',').map do |email|
			user = User.find_by(email: email)
			if not user
				respond(ERR_INVALID_FIELD)
				return
			end
			user.id
		end

		event.add_user_list(user_list)
		event.add_to_user_event_lists(user_list)
		event.notify( EventNotification.new(NOTIF_NEW_EVENT, event), user_list)

	end

	private

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
