require 'user'

class EventsController < ApplicationController

	# Success return code
	SUCCESS = 1
	# Invalid name: Name must exist and have max length @@MAX_NAME_LENGTH
	ERR_INVALID_NAME = -1 
	# Invalid time: Time must be a valid time
	ERR_INVALID_TIME = -10
	# Invalid field: Generic, one of the fields is invalid. 
	ERR_INVALID_FIELD = -6
	# Generic error for an unsuccessful action
	ERR_UNSUCCESSFUL = -7

	# Possible user statuses in respect to an event. 
	STATUS_NO_RESPONSE = 0
	STATUS_ATTENDING = 1
	STATUS_NOT_ATTENDING = -1

	# POST /event/create_event
	# Creates a new event and stores it in the db
	# * On success, stores the event in the database
	# * On success, adds the event to each invited user
	# * On success, returns JSON { err_code: SUCCESS, :event}
	# * On failure, returns JSON { :err_code }
	def create_event
		creator = current_user
		
		user_list = {}
		params[:user_list].split(",").each do |s|
			if !is_valid_user_id?(s)
				respond(ERR_UNSUCCESSFUL)
				return
			else
				user_id = Integer(s, 10)
				user_list[user_id] = { status: STATUS_NO_RESPONSE }
			end
		end

		@event = Event.new(name: params[:name], admin: creator, description: params[:description], location: params[:location], party_list: user_list)
		
		# Need to add time there as well
		
		rval = @event.is_valid?
		if rval < 0
  		respond(rval)
  		return
  	end
		success = @event.save
		if !success
			respond(ERR_UNSUCCESSFUL)
			return
		end
		
		user_list.each_key do |users_id|
			users_id.add_event(@event.id)

			# Also add to their notifications here!

		end

		respond(SUCCESS, { event: @event.id} )
  end



	private
	
	# Takes in a string, USER_ID, and checks if it is a valid 
	# user id
	def is_valid_user_id?(user_id)
		begin 
				User.find(Integer(user_id, 10))
		rescue ActiveRecord::RecordNotFound, ArgumentError
				return false
		end		
		return true
	end

	# Responds. Always includes err_code set to ERROR (SUCCESS by default). 
	# Additional response fields can be passed as a hash to ADDITIONAL.
	def respond(error = @@SUCCESS, additional = {})
		response = { err_code: error }.merge(additional)
		 respond_to do |format|
  		format.html { render json: response, content_type: "application/json" }
  		format.json { render json: response, content_type: "application/json" }
  	end
	end

  # Finds the User with the remember_token stored in the session with the key :current_user_token
  # Logging in sets the session value and logging out removes it.
  def current_user
  	token = User.hash(cookies[:current_user_token])
  	return User.find_by(remember_token: token)
  end

end
