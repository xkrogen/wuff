include RestGraph::RailsUtil

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
  		current_user = @user
      respond(rval, { user_id: current_user.id,  email: current_user.email, name: current_user.name })
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
  		current_user = @user
      respond(rval[:err_code], { user_id: current_user.id, email: current_user.email, name: current_user.name })
  	end
  end

  # POST /user/auth_facebook
  def auth_facebook
    @user = User.find_by(fb_id: params[:facebook_id])
    if @user == nil
      begin
        rest_graph_setup
        rg = RestGraph.new(:access_token => params[:facebook_token])
        medata = rg.get('me')
        @user = User.find_by(email: medata['email'])
        if @user == nil
          @user = User.new(name: medata['name'], email:  medata['email'], password: SecureRandom.urlsafe_base64)
          @user.add
        end
      rescue => exception
        respond(ERR_BAD_CREDENTIALS)
        return
      end
    end
    token = User.new_token
    cookies.permanent[:current_user_token] = token
    @user.update_attribute(:remember_token, User.hash(token))
    @user.update_attribute(:fb_id, params[:facebook_id])
    current_user = @user
    respond(SUCCESS, { user_id: current_user.id, email: current_user.email, name: current_user.name })
  end


  # GET /user/get_all_users
  # Return a list of all users signed up for Wuff
  # (Used for autocompletion purposes)
  def get_all_users
    user_count = 0
    user_list = {}
    User.all.each do |user|
      user_count += 1
      user_list[user_count] = user.get_hash
    end
    user_list[:count] = user_count
    respond(SUCCESS, user_list)
  end

  # DELETE /user/logout_user
  # Logout the current_user
  # * Changes current_user's remember_token in database
  # * Deletes cookies[current_user_token] and set current_user = nil
  def logout_user
    if !current_user.nil?
  	 token = User.new_token
  	 current_user.update_attribute(:remember_token, User.hash(token))
  	 cookies.delete(:current_user_token)
  	 current_user = nil
    end
    respond(SUCCESS)
  end

  # POST /user/add_friend
  # Calls current_user.concat_friend
  def add_friend
    if not signed_in?
      session_fail_response
      return
    end
    rval = current_user.concat_friend(params[:friend_email])
    respond(rval)
  end

  # DELETE /user/delete_friend
  # Calls current_user.remove_friend
  def delete_friend
    if not signed_in?
      session_fail_response
      return
    end
    rval = current_user.remove_friend(params[:friend_email])
    respond(rval)
  end

  # GET /user/get_events
  # Returns all of the relevant information to display user_id’s events 
  # on their main screen. Nested JSON for each event.  
  #
  # If invalid event IDs are found, automatically removes them from
  # the user's event list. 
  def get_events
    if not signed_in?
      session_fail_response
      return
    end
    return_list = {}
    event_count = 0
    user = current_user
    event_list_size_old = user.event_list.size
    user.event_list.delete_if do |event_id|
      begin
        event = Event.find(event_id)
      rescue ActiveRecord::RecordNotFound
        next true
      end
      event_count += 1
      return_list[event_count] = event.get_hash
      false
    end
    user.update_attribute(:event_list, user.event_list) if event_list_size_old != user.event_list.size
    return_list[:event_count] = event_count
    respond(SUCCESS, return_list)
  end


  # GET /user/get_groups
  # Returns all of the relevant information to display user_id’s groups. 
  # Nested JSON for each group. 
  #
  # If invalid group IDs are found, automatically removes them from
  # the user's group list. 
  def get_groups
    if not signed_in?
      session_fail_response
      return
    end
    return_list = {}
    group_count = 0
    user = current_user
    group_list_size_old = user.group_list.size
    user.group_list.delete_if do |group_id|
      begin
        group = Group.find(group_id)
      rescue ActiveRecord::RecordNotFound
        next true
      end
      group_count += 1
      return_list[group_count] = group.get_hash
      false
    end
    user.update_attribute(:group_list, user.group_list) if group_list_size_old != user.group_list.size
    return_list[:group_count] = group_count
    respond(SUCCESS, return_list)
  end

  # GET /user/has_notifications
  # Check if the user.notification_list is empty
  # Upon success, format JSON { err_code: code, notif: val }
  def has_notifications?
    if not signed_in?
      session_fail_response
      return
    end
    val = current_user.notification_list.size >= 1
    respond(SUCCESS, { notif: val })
  end

  # GET /user/get_notifications
  # Returns a list of pending notifications as JSON
  def get_notifications
    if not signed_in?
      session_fail_response
      return
    end
    return_list = {}
    notif_count = 0
    current_user.notification_list.each do |notif|
      notif_count += 1
      return_list[notif_count] = notif
    end
    return_list[:notif_count] = notif_count
    respond(SUCCESS, return_list)
  end

  # DELETE /user/clear_notifications
  # Upon Success, the current_user.notification_list is empty
  def clear_notifications
    if not signed_in?
      session_fail_response
      returns
    end
    current_user.update_attribute(:notification_list, Array.new)
    respond(SUCCESS)
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
