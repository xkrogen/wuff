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

		user_list = params[:user_list].split(",").map do |s|
			begin 
				user_id = Integer(s, 10)
			rescue ArgumentError
				respond(ERR_INVALID_FIELD)
				return
			end
			user_id
		end

		rval = Event.add_event(params[:name], creator.id, params[:time].to_i,
			user_list, params[:description], params[:location])

		if rval < 0
  		respond(rval)
  	else
  		respond(SUCCESS, { event: rval } )
  	end
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
