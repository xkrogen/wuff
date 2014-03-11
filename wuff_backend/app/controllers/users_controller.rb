class UsersController < ApplicationController

   # Session ID does not match this user.remember_token
  ERR_INVALID_SESSION = -11

	# POST /user/add_user
	# Tries to store user in db using User#add
	# * On success, stores user in database
	# * On success, stores cookie to remember session and sets the current_user to this user
	# * On success, returns JSON { :err_code, : user_id }
	# * On failure, returns JSON { :err_code }
  def add_user
  	@user = User.new(name: params[:name], email: params[:email], password: params[:password])
    rval = @user.add
  	if rval < 0
      respond(rval)
  	else
  		token = User.new_token
  		cookies.permanent[:current_user_token] = token
  		@user.update_attribute(:remember_token, User.hash(token))
  		self.current_user = @user
      respond(rval, { user_id: current_user.id })
  	end
  end

  # POST /user/login_user
  # Tries to login user in using User#login
	# * On success, stores cookie to remember session and sets the current_user to this user
	# * On success, returns JSON { :err_code, : user_id }
	# * On failure, returns JSON { :err_code }
  def login_user
  	@user = User.new(email: params[:email], password: params[:password])
  	rval = @user.login
  	if rval[:err_code] < 0
      respond(rval[:err_code])
  	else
  		@user = rval[:user]
  		token = User.new_token
  		cookies.permanent[:current_user_token] = token
  		@user.update_attribute(:remember_token, User.hash(token))
  		self.current_user = @user
      respond(rval[:err_code], { user_id: current_user.id })
  	end
  end

  # POST /user/logout_user
  # Logout the current_user
  # * Changes current_user's remember_token in database
  # * Deletes cookies[current_user_token] and set current_user = nil
  def logout_user
  	token = User.new_token
  	current_user.update_attribute(:remember_token, User.hash(token))
  	cookies.delete(:current_user_token)
  	self.current_user = nil
  end

  # POST /user/add_friend
  # Calls current_user.concat_friend
  def add_friend
    if signed_in?
      rval = self.current_user.concat_friend(params[:friend_email])
      respond(rval)
    else
      session_fail_response
    end
  end

  # DELETE /user/delete_friend
  # Calls current_user.remove_friend
  def delete_friend
    if signed_in?
      rval = self.current_user.remove_friend(params[:friend_email])
      respond(rval)
    else
      session_fail_response
    end
  end

  # GET /user/get_events
  # Returns all of the relevant information to display user_id’s events 
  # on their main screen. Nested JSON for each event. user_list is a 
  # comma separated list of user IDs with no spaces, 
  # i.e.“user_id1,user_id2,user_id3”. list_of_states is the same format 
  # in the same order, with the user’s status (STATUS_NO_RESPONSE, 
  # STATUS_ATTENDING, STATUS_NOT_ATTENDING) instead of user IDs. 

  # NEEDS TESTING!

  def get_events
    event_list = {}
    event_count = 0
    event_list.delete_if do |event_id|
      begin 
        event = Event.find(event_id)
      rescue ActiveRecord::RecordNotFound
        return true
      end
      event_count += 1
      event_list[event_count] = event.get_hash
      false
    end
    respond(SUCCESS, event_list)
  end

  private

  # Responds. Always includes err_code set to ERROR (SUCCESS by default).
  # Additional response fields can be passed as a hash to ADDITIONAL.
  def respond(error = SUCCESS, additional = {})
    response = { err_code: error }.merge(additional)
    respond_to do |format|
      format.html { render json: response, content_type: "application/json" }
      format.json { render json: response, content_type: "application/json" }
    end
  end

  def session_fail_response
    response = { err_code: ERR_INVALID_SESSION }
    respond_to do |format|
      format.html { render json: response, content_type: "application/json" }
      format.json { render json: response, content_type: "application/json" }
    end
  end

  # Checks to see if there is a signed in user
  def signed_in?
  	!current_user.nil?
  end

  # Sets the current_user to a user
  def current_user=(user)
  	@current_user = user
  end

  # Finds the User with the remember_token stored in the session with the key :current_user_token
  # Logging in sets the session value and logging out removes it.
  def current_user
  	token = User.hash(cookies[:current_user_token])
  	@current_user ||= User.find_by(remember_token: token)
  end

end
